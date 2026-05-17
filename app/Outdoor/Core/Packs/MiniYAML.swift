import Foundation

/// Tiny YAML reader tailored to the two files we ship: `manifest.yaml` and
/// `safety_rules.yaml`. Not a general YAML parser — supports only the subset
/// the pack-builder emits: scalars, nested mappings (one level), lists of
/// scalars, lists of mappings, and folded block scalars (`>`).
///
/// We avoid pulling in a YAML dependency for a couple hundred lines of code.
/// If we ever need more, we can swap this for `Yams` without changing callers.
enum MiniYAML {

    // MARK: - Manifest

    static func parseManifest(_ text: String) -> PackManifest {
        let root = parseDocument(text)
        let domains: [String] = {
            if case .list(let items)? = root["content_domains"] {
                return items.compactMap { if case .scalar(let s) = $0 { return s } else { return nil } }
            }
            return []
        }()
        return PackManifest(
            id: scalar(root["id"]) ?? "unknown",
            version: scalar(root["version"]) ?? "0.0.0",
            displayName: scalar(root["display_name"]) ?? "Pack",
            description: scalar(root["description"]) ?? "",
            domains: domains,
            chunkCount: Int(scalar(root["chunk_count"]) ?? "0") ?? 0,
            sourceCount: Int(scalar(root["source_count"]) ?? "0") ?? 0,
            createdAt: scalar(root["created_at"])
        )
    }

    // MARK: - Safety rules

    static func parseSafetyRules(_ text: String) -> [SafetyRule] {
        guard case .list(let items) = parseValue(text) else { return [] }
        return items.compactMap { item -> SafetyRule? in
            guard case .mapping(let map) = item else { return nil }
            let intent = scalar(map["intent"]) ?? "general"
            let answerMode = scalar(map["answer_mode"]) ?? "rag_freeform"
            let risk = scalar(map["risk"]) ?? "low"
            let match = list(map["match"])
            let mustInclude = list(map["must_include"])
            let refuse = list(map["refuse_patterns"])
            return SafetyRule(
                intent: intent,
                match: match,
                risk: risk,
                answerMode: answerMode,
                mustInclude: mustInclude,
                refusePatterns: refuse
            )
        }
    }

    // MARK: - Parsing

    /// Internal value tree.
    private indirect enum Node {
        case scalar(String)
        case list([Node])
        case mapping([String: Node])
    }

    private static func parseDocument(_ text: String) -> [String: Node] {
        if case .mapping(let m) = parseValue(text) { return m }
        return [:]
    }

    private static func parseValue(_ text: String) -> Node {
        let lines = preprocess(text)
        return parseBlock(lines, baseIndent: 0).0
    }

    /// Strip comments and trailing whitespace, but keep blank lines as separators.
    private static func preprocess(_ text: String) -> [Line] {
        var out: [Line] = []
        for raw in text.components(separatedBy: "\n") {
            let withoutComment = stripComment(raw)
            let trimmed = withoutComment.replacingOccurrences(of: "\t", with: "  ")
            // Skip pure-blank lines but keep their absence noted.
            let stripped = trimmed.trimmingCharacters(in: .whitespaces)
            if stripped.isEmpty { continue }
            let indent = trimmed.prefix(while: { $0 == " " }).count
            out.append(Line(indent: indent, text: stripped))
        }
        return out
    }

    private static func stripComment(_ s: String) -> String {
        var inSingle = false
        var inDouble = false
        var out = ""
        for ch in s {
            if ch == "\"" && !inSingle { inDouble.toggle() }
            else if ch == "'" && !inDouble { inSingle.toggle() }
            if ch == "#" && !inSingle && !inDouble { break }
            out.append(ch)
        }
        return out
    }

    private struct Line {
        let indent: Int
        let text: String
    }

    /// Parse a block starting at `lines[0]`. Consumes lines whose indent ≥ baseIndent.
    /// Returns the parsed node + number of lines consumed.
    private static func parseBlock(_ lines: [Line], baseIndent: Int) -> (Node, Int) {
        guard !lines.isEmpty else { return (.mapping([:]), 0) }

        if lines[0].text.hasPrefix("- ") || lines[0].text == "-" {
            return parseListBlock(lines, baseIndent: baseIndent)
        } else {
            return parseMappingBlock(lines, baseIndent: baseIndent)
        }
    }

    private static func parseListBlock(_ lines: [Line], baseIndent: Int) -> (Node, Int) {
        var items: [Node] = []
        var i = 0
        while i < lines.count {
            let line = lines[i]
            if line.indent < baseIndent { break }
            guard line.indent == baseIndent, line.text.hasPrefix("-") else {
                break
            }
            // Body of the list item.
            let rest = String(line.text.dropFirst()).trimmingCharacters(in: .whitespaces)

            // Inline: "- scalar" or "- key: value"
            if !rest.isEmpty {
                if let colonIdx = rest.firstIndex(of: ":"),
                   colonIdx != rest.index(before: rest.endIndex) || rest.hasSuffix(":") {
                    // Mapping item: synthesize a sub-block starting with this kv pair
                    // followed by any further-indented lines.
                    var subLines: [Line] = []
                    subLines.append(Line(indent: 0, text: rest))
                    var j = i + 1
                    while j < lines.count, lines[j].indent > baseIndent {
                        subLines.append(Line(indent: lines[j].indent - (baseIndent + 2),
                                             text: lines[j].text))
                        j += 1
                    }
                    let (sub, _) = parseMappingBlock(subLines, baseIndent: 0)
                    items.append(sub)
                    i = j
                } else {
                    items.append(.scalar(unquote(rest)))
                    i += 1
                }
            } else {
                // "-" by itself, next-indented lines are the body
                var j = i + 1
                var subLines: [Line] = []
                while j < lines.count, lines[j].indent > baseIndent {
                    subLines.append(Line(indent: lines[j].indent - (baseIndent + 2),
                                         text: lines[j].text))
                    j += 1
                }
                let (sub, _) = parseBlock(subLines, baseIndent: 0)
                items.append(sub)
                i = j
            }
        }
        return (.list(items), i)
    }

    private static func parseMappingBlock(_ lines: [Line], baseIndent: Int) -> (Node, Int) {
        var map: [String: Node] = [:]
        var i = 0
        while i < lines.count {
            let line = lines[i]
            if line.indent < baseIndent { break }
            guard line.indent == baseIndent else { i += 1; continue }
            // Find first colon that's not inside quotes
            guard let colonIdx = findKeyColon(line.text) else { i += 1; continue }
            let key = String(line.text[..<colonIdx]).trimmingCharacters(in: .whitespaces)
            let after = String(line.text[line.text.index(after: colonIdx)...])
                .trimmingCharacters(in: .whitespaces)

            if after.isEmpty || after == ">" || after == "|" || after == ">-" || after == "|-" {
                // Block follows.
                let folded = (after == ">" || after == ">-")
                let literal = (after == "|" || after == "|-")
                if folded || literal {
                    // Collect block scalar lines.
                    var j = i + 1
                    var buf: [String] = []
                    while j < lines.count, lines[j].indent > baseIndent {
                        buf.append(lines[j].text)
                        j += 1
                    }
                    let joined = folded ? buf.joined(separator: " ") : buf.joined(separator: "\n")
                    map[key] = .scalar(unquote(joined))
                    i = j
                } else {
                    // Nested mapping or list.
                    var subLines: [Line] = []
                    var j = i + 1
                    while j < lines.count, lines[j].indent > baseIndent {
                        subLines.append(Line(indent: lines[j].indent - (baseIndent + 2),
                                             text: lines[j].text))
                        j += 1
                    }
                    if subLines.isEmpty {
                        map[key] = .scalar("")
                        i += 1
                    } else {
                        let (node, _) = parseBlock(subLines, baseIndent: 0)
                        map[key] = node
                        i = j
                    }
                }
            } else {
                map[key] = .scalar(unquote(after))
                i += 1
            }
        }
        return (.mapping(map), i)
    }

    private static func findKeyColon(_ s: String) -> String.Index? {
        var inSingle = false
        var inDouble = false
        for idx in s.indices {
            let ch = s[idx]
            if ch == "\"" && !inSingle { inDouble.toggle() }
            else if ch == "'" && !inDouble { inSingle.toggle() }
            if ch == ":" && !inSingle && !inDouble {
                return idx
            }
        }
        return nil
    }

    private static func unquote(_ s: String) -> String {
        var out = s.trimmingCharacters(in: .whitespaces)
        if (out.hasPrefix("\"") && out.hasSuffix("\"")) ||
           (out.hasPrefix("'") && out.hasSuffix("'")), out.count >= 2 {
            out = String(out.dropFirst().dropLast())
        }
        return out
    }

    // MARK: - Helpers used by callers above

    private static func scalar(_ node: Node?) -> String? {
        if case .scalar(let s)? = node { return s }
        return nil
    }

    private static func list(_ node: Node?) -> [String] {
        if case .list(let items)? = node {
            return items.compactMap { if case .scalar(let s) = $0 { return s } else { return nil } }
        }
        return []
    }
}
