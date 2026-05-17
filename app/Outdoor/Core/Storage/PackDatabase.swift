import Foundation

/// Type-safe queries against a single pack.sqlite file.
///
/// All retrieval and metadata reads go through this class. The DB is opened
/// read-only — packs are signed artifacts, not user-writable.
final class PackDatabase {
    private let db: SQLiteDB

    init(packDatabaseURL: URL) throws {
        self.db = try SQLiteDB(path: packDatabaseURL.path, readOnly: true)
    }

    // MARK: - Counts and inventory

    func chunkCount() throws -> Int {
        let rows = try db.query("SELECT COUNT(*) FROM chunks") { Int($0.int(0)) }
        return rows.first ?? 0
    }

    func sourceCount() throws -> Int {
        let rows = try db.query("SELECT COUNT(*) FROM sources") { Int($0.int(0)) }
        return rows.first ?? 0
    }

    func availableDomains() throws -> [String] {
        try db.query("SELECT DISTINCT domain FROM chunks ORDER BY domain") { $0.text(0) }
    }

    // MARK: - Browse by domain

    /// One representative chunk per file in a domain (`section_index = 0`),
    /// for the Guide tab's domain list. Scores are zero — these aren't search results.
    func topicsInDomain(_ domain: String) throws -> [RetrievedChunk] {
        let sql = """
        SELECT c.chunk_id, c.section_title, c.chunk_text, c.domain, c.topic,
               c.hazard_level, c.tags_json,
               s.title, s.publisher, s.url, s.license
        FROM chunks c
        LEFT JOIN sources s ON s.source_key = c.source_key
        WHERE c.domain = ? AND c.section_index = 0
        ORDER BY c.topic, c.chunk_id
        """
        return try db.query(sql, bind: [.text(domain)]) { stmt in
            Self.decodeBrowseChunk(stmt)
        }
    }

    func chunk(byID id: String) throws -> RetrievedChunk? {
        let sql = """
        SELECT c.chunk_id, c.section_title, c.chunk_text, c.domain, c.topic,
               c.hazard_level, c.tags_json,
               s.title, s.publisher, s.url, s.license
        FROM chunks c
        LEFT JOIN sources s ON s.source_key = c.source_key
        WHERE c.chunk_id = ?
        """
        let rows = try db.query(sql, bind: [.text(id)]) { stmt in
            Self.decodeBrowseChunk(stmt)
        }
        return rows.first
    }

    // MARK: - Search (FTS5 keyword retrieval)

    /// Pure FTS5 keyword retrieval for v1. Vector similarity gets layered in
    /// when sqlite-vec ships on iOS — the result shape is identical so callers
    /// don't change.
    ///
    /// Stopwords are filtered before forming the FTS query so common words
    /// like "the" / "I" don't dominate BM25 ranking. Scores are normalized
    /// to [0, 1] per the retrieval contract.
    ///
    /// - Parameters:
    ///   - query: the user's natural-language question
    ///   - limit: max chunks returned (`k` in the contract)
    ///   - keywordWeight: weight for keyword score in the hybrid (default 0.3)
    ///   - vectorWeight: weight for vector score (default 0.7) — unused in v1
    func search(
        _ query: String,
        limit: Int = 5,
        keywordWeight: Double = 0.3,
        vectorWeight: Double = 0.7
    ) throws -> [RetrievedChunk] {
        // Expand colloquial phrasings to canonical terms ("epi pen" → "epinephrine")
        // before tokenizing. Keeps the user's own words too, just adds synonyms.
        let expanded = Self.expandSynonyms(query)
        let terms = Self.tokenize(expanded)
        guard !terms.isEmpty else { return [] }
        let ftsExpr = terms.map { "\"\($0)\"" }.joined(separator: " OR ")

        // bm25 column weights match the chunks_fts schema's indexed columns:
        // section_title (4x) > tags (2x) > chunk_text (1x). Titles are short
        // and topical, so matching the title is a much stronger signal than
        // matching a body word.
        let sql = """
        SELECT c.chunk_id, c.section_title, c.chunk_text, c.domain, c.topic,
               c.hazard_level, c.tags_json,
               s.title, s.publisher, s.url, s.license,
               bm25(chunks_fts, 4.0, 1.0, 2.0) AS bm25_score
        FROM chunks_fts
        JOIN chunks c ON c.chunk_id = chunks_fts.chunk_id
        LEFT JOIN sources s ON s.source_key = c.source_key
        WHERE chunks_fts MATCH ?
        ORDER BY bm25_score
        LIMIT ?
        """

        // Pull more raw results than the caller asked for, so the relative-
        // strength filter below has a real population to compare against.
        // bm25() returns lower=better; flip sign so higher=better.
        let oversampleLimit = max(limit * 4, 12)
        let rawAll = try db.query(
            sql,
            bind: [.text(ftsExpr), .int(Int64(oversampleLimit))]
        ) { stmt -> (Decoded, Double) in
            (Self.decodeRow(stmt), -stmt.double(11))
        }

        // Drop weak hits BEFORE min-max normalization. Without this step,
        // min-max guarantees the worst chunk in the result set scores 0.0
        // and the best 1.0 — pulling marginally-related chunks above the
        // PromptBuilder threshold even when their absolute BM25 is poor.
        //
        // Two guards:
        //   1. Relative: keep only chunks within 60% of the top raw score.
        //   2. Absolute: drop anything below MIN_USEFUL_BM25 outright.
        let MIN_USEFUL_BM25 = 3.0      // tuned empirically against the camping pack
        let RELATIVE_CUTOFF = 0.60     // keep top, ≥ 60% of top's raw score
        let raw: [(Decoded, Double)]
        if let top = rawAll.map(\.1).max(), top >= MIN_USEFUL_BM25 {
            let floor = max(MIN_USEFUL_BM25, top * RELATIVE_CUTOFF)
            raw = Array(rawAll.filter { $0.1 >= floor }.prefix(limit))
        } else {
            // No useful hits — return empty so the caller emits the
            // "pack doesn't cover this" refusal cleanly.
            return []
        }

        // Map raw BM25 → [0, 1] via an absolute linear projection rather
        // than min-max. Min-max forces the second-best result toward 0 even
        // when it's a perfectly good match, which causes PromptBuilder to
        // drop everything except the top result. With a calibrated absolute
        // map, scores are stable across queries:
        //
        //   raw  0     →  score 0.0   (filtered out earlier, anyway)
        //   raw  4     →  score 0.4   (weakMatchThreshold)
        //   raw  6     →  score 0.6   (strongMatchThreshold)
        //   raw 10+    →  score 1.0   (excellent match)
        let RAW_FULL_SCORE = 10.0
        var keywordScores: [Double] = raw.map { (_, r) in
            min(1.0, max(0.0, r / RAW_FULL_SCORE))
        }

        // Section-title overlap boost. The user's query intent often lives in
        // the section title — "what does poison oak look like" should rank the
        // "Identification" section above "Burning is dangerous". Boost is
        // capped at +0.35 so it nudges rather than overrides BM25.
        let queryTokens = Set(Self.tokenize(query))
        if !queryTokens.isEmpty {
            for i in raw.indices {
                let titleTokens = Set(Self.tokenize(raw[i].0.sectionTitle))
                let overlap = queryTokens.intersection(titleTokens).count
                if overlap == 0 { continue }
                // Boost grows with overlap but saturates fast: 1 term ≈ +0.18,
                // 2 ≈ +0.28, 3+ ≈ +0.35.
                let boost = min(0.35, Double(overlap) * 0.18)
                keywordScores[i] = min(1.0, keywordScores[i] + boost)
            }
        }

        // Build RetrievedChunks. Vector score is 0.0 until sqlite-vec lands on iOS.
        //
        // While the vector path is offline, fall back to keyword-only scoring
        // for `scoreHybrid`. The naive formula
        //     scoreHybrid = keywordWeight*kw + vectorWeight*0
        // would give a max of 0.3 with default weights, which is below
        // PromptBuilder.weakMatchThreshold (0.4) and causes every query to
        // be filtered out as "no relevant chunks". When the vector index
        // comes online, restore the hybrid weighting.
        let _ = (keywordWeight, vectorWeight)  // weights intentionally ignored in v1
        let out: [RetrievedChunk] = zip(raw, keywordScores).map { (pair, kwScore) in
            let d = pair.0
            let hybrid = kwScore   // TODO(phase3-vectors): keywordWeight*kw + vectorWeight*vec
            return RetrievedChunk(
                chunkId: d.chunkId,
                sectionTitle: d.sectionTitle,
                text: d.text,
                domain: d.domain,
                topic: d.topic,
                hazardLevel: HazardLevel(raw: d.hazardLevelRaw),
                tags: d.tags,
                sourceTitle: d.sourceTitle,
                sourcePublisher: d.sourcePublisher,
                sourceURL: d.sourceURL,
                sourceLicense: d.sourceLicense,
                scoreKeyword: kwScore,
                scoreVector: 0.0,
                scoreHybrid: hybrid
            )
        }

        // Contract guarantee: sorted by scoreHybrid descending.
        return out.sorted { $0.scoreHybrid > $1.scoreHybrid }
    }

    // MARK: - Row decoding

    /// Intermediate shape held during decode + score normalization.
    private struct Decoded {
        let chunkId: String
        let sectionTitle: String
        let text: String
        let domain: String
        let topic: String?
        let hazardLevelRaw: String
        let tags: [String]
        let sourceTitle: String
        let sourcePublisher: String
        let sourceURL: String
        let sourceLicense: String
    }

    private static func decodeRow(_ stmt: Statement) -> Decoded {
        let tagsJSON = stmt.text(6)
        let tags: [String] = {
            guard let data = tagsJSON.data(using: .utf8),
                  let arr = try? JSONSerialization.jsonObject(with: data) as? [String]
            else { return [] }
            return arr
        }()
        return Decoded(
            chunkId: stmt.text(0),
            sectionTitle: stmt.text(1),
            text: stmt.text(2),
            domain: stmt.text(3),
            topic: stmt.textOrNil(4),
            hazardLevelRaw: stmt.text(5),
            tags: tags,
            sourceTitle: stmt.textOrNil(7) ?? "",
            sourcePublisher: stmt.textOrNil(8) ?? "",
            sourceURL: stmt.textOrNil(9) ?? "",
            sourceLicense: stmt.textOrNil(10) ?? ""
        )
    }

    private static func decodeBrowseChunk(_ stmt: Statement) -> RetrievedChunk {
        let d = decodeRow(stmt)
        return RetrievedChunk(
            chunkId: d.chunkId,
            sectionTitle: d.sectionTitle,
            text: d.text,
            domain: d.domain,
            topic: d.topic,
            hazardLevel: HazardLevel(raw: d.hazardLevelRaw),
            tags: d.tags,
            sourceTitle: d.sourceTitle,
            sourcePublisher: d.sourcePublisher,
            sourceURL: d.sourceURL,
            sourceLicense: d.sourceLicense,
            scoreKeyword: 0,
            scoreVector: 0,
            scoreHybrid: 0
        )
    }

    // MARK: - Tokenization

    private static let stopwords: Set<String> = [
        "a", "an", "the", "and", "or", "but", "if", "of", "to", "in", "on", "at",
        "is", "are", "was", "were", "be", "been", "being",
        "i", "you", "he", "she", "we", "they", "it", "my", "your", "our",
        "do", "does", "did", "will", "would", "should", "could", "can",
        "have", "has", "had", "this", "that", "these", "those",
        "for", "with", "from", "by", "as", "so",
        "what", "how", "when", "where", "why", "who", "which",
        "see", "get", "got", "go", "going"
    ]

    static func tokenize(_ query: String) -> [String] {
        let raw = query.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        let filtered = raw.filter { $0.count > 1 && !stopwords.contains($0) }
        return filtered.isEmpty ? raw : filtered
    }

    // MARK: - Synonym expansion

    /// Colloquial → canonical term map. Keys are substring-matched (case-
    /// insensitive); when a key appears in the query, the values are appended
    /// to the search terms. Keeps the user's own words too.
    private static let synonyms: [(String, [String])] = [
        ("epi pen",         ["epinephrine", "epipen", "auto-injector"]),
        ("epipen",          ["epinephrine", "auto-injector"]),
        ("broken arm",      ["fracture", "splint"]),
        ("broken leg",      ["fracture", "splint"]),
        ("broken bone",     ["fracture", "splint"]),
        ("broken finger",   ["fracture", "splint"]),
        ("broken rib",      ["fracture", "rib"]),
        ("twisted ankle",   ["sprain", "ankle", "RICE"]),
        ("sprained ankle",  ["sprain", "RICE", "ice"]),
        ("food poisoning",  ["diarrhea", "vomiting", "gi", "hydration"]),
        ("stomach bug",     ["diarrhea", "vomiting", "gi", "hydration"]),
        ("stomach ache",    ["diarrhea", "abdominal", "gi"]),
        ("fire from sticks",["primitive", "bow drill", "friction"]),
        ("fire by friction",["bow drill", "primitive", "spindle"]),
        ("fire with sticks",["primitive", "bow drill", "friction"]),
        ("no lighter",      ["primitive", "ferro", "bow drill", "matches"]),
        ("no matches",      ["primitive", "ferro", "lighter"]),
        ("char cloth",      ["tinder", "ferro", "ember"]),
        ("tinderbox",       ["tinder", "char cloth", "ferro"]),
        ("kid acting",      ["altitude", "hypothermia", "dehydration", "child"]),
        ("child acting",    ["altitude", "hypothermia", "dehydration"]),
        ("set up tent",     ["pitch", "tent setup", "stakes"]),
        ("pitch tent",      ["tent setup", "stakes", "guyline"]),
        ("pitching tent",   ["tent setup", "stakes", "guyline"]),
        ("wading",          ["river crossing", "ford", "stream crossing"]),
        ("ford a stream",   ["river crossing", "wading"]),
        ("wet feet",        ["trench foot", "dry socks", "blister"]),
        ("bug bites",       ["mosquito", "tick", "permethrin", "deet"]),
        ("fog navigation",  ["handrail", "compass bearing", "pace"]),
        ("navigate in fog", ["handrail", "whiteout", "compass bearing", "pace"]),
        ("in fog",          ["handrail", "whiteout", "compass"]),
        ("how far walked",  ["pace count", "naismith", "distance estimation"]),
        ("how far have we", ["pace count", "naismith", "distance"]),
        ("signal help",     ["whistle", "mirror", "PLB", "three"]),
        ("signal for help", ["whistle", "mirror", "PLB", "three", "signal fire"]),
        ("kid is acting",   ["altitude", "hypothermia", "dehydration", "child"]),
        ("child is acting", ["altitude", "hypothermia", "dehydration"]),
        ("acting weird",    ["altered mental", "altitude", "hypothermia"]),
        ("build a campfire",["teepee", "tinder", "kindling", "lay"]),
        ("build a fire",    ["teepee", "tinder", "kindling", "lay"]),
    ]

    /// Append canonical synonym terms when a colloquial key appears in the
    /// query. Idempotent — duplicates are deduped by the tokenizer.
    static func expandSynonyms(_ query: String) -> String {
        let lower = query.lowercased()
        var extras: [String] = []
        for (key, syns) in synonyms where lower.contains(key) {
            extras.append(contentsOf: syns)
        }
        return extras.isEmpty ? query : "\(query) \(extras.joined(separator: " "))"
    }
}
