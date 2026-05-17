import Foundation

/// Hazard level — typed enum per the retrieval contract
/// (`docs/retrieval-llm-contract.md`).
public enum HazardLevel: String, Sendable, Codable, Hashable, CaseIterable {
    case low, medium, high, critical

    /// Tolerant decoder for the strings the pack-builder emits ("high",
    /// "Critical", "  low  ", etc.). Anything unrecognized falls back to `.low`.
    public init(raw: String) {
        let key = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self = HazardLevel(rawValue: key) ?? .low
    }
}

/// A retrieved content chunk — the unit of knowledge returned by the Retriever.
///
/// Flat-fields shape per `docs/retrieval-llm-contract.md`: the iOS app, Python
/// CLI, and Phase 3 PromptBuilder all consume this exact structure.
public struct RetrievedChunk: Identifiable, Hashable, Sendable {
    public let chunkId: String            // e.g. "first-aid.bleeding-control#1"
    public let sectionTitle: String
    public let text: String
    public let domain: String
    public let topic: String?             // not in the contract but useful for browse UI
    public let hazardLevel: HazardLevel
    public let tags: [String]
    public let sourceTitle: String
    public let sourcePublisher: String
    public let sourceURL: String          // may be empty per contract
    public let sourceLicense: String      // useful in the citation sheet
    public let scoreKeyword: Double       // 0..1 normalized BM25
    public let scoreVector: Double        // 0..1 normalized cosine (0.0 in v1, no vector index yet)
    public let scoreHybrid: Double        // weighted combo, used for ranking

    public var id: String { chunkId }

    /// Best-effort short citation label for the chip UI.
    public var citationLabel: String {
        if !sourcePublisher.isEmpty { return sourcePublisher }
        if !sourceTitle.isEmpty { return sourceTitle }
        return "Source"
    }
}

/// Pack metadata loaded from manifest.yaml.
public struct PackManifest: Hashable, Sendable {
    public let id: String
    public let version: String
    public let displayName: String
    public let description: String
    public let domains: [String]
    public let chunkCount: Int
    public let sourceCount: Int
    public let createdAt: String?

    /// Display tagline pulled from manifest description.
    public var tagline: String {
        description
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// A pack installed on device — manifest + filesystem location.
public struct InstalledPack: Identifiable, Hashable, Sendable {
    public let manifest: PackManifest
    public let rootURL: URL
    public let packDatabaseURL: URL

    public var id: String { manifest.id }
}

/// A pack that isn't yet available — used to tease future content.
public struct PackPreview: Hashable, Sendable {
    public let id: String
    public let displayName: String
    public let description: String
    public let symbol: String
    public let tint: String      // hex string for tint
}
