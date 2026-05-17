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
        let terms = Self.tokenize(query)
        guard !terms.isEmpty else { return [] }
        let ftsExpr = terms.map { "\"\($0)\"" }.joined(separator: " OR ")

        let sql = """
        SELECT c.chunk_id, c.section_title, c.chunk_text, c.domain, c.topic,
               c.hazard_level, c.tags_json,
               s.title, s.publisher, s.url, s.license,
               bm25(chunks_fts) AS bm25_score
        FROM chunks_fts
        JOIN chunks c ON c.chunk_id = chunks_fts.chunk_id
        LEFT JOIN sources s ON s.source_key = c.source_key
        WHERE chunks_fts MATCH ?
        ORDER BY bm25_score
        LIMIT ?
        """

        // bm25() returns lower=better; flip sign so higher=better.
        var raw = try db.query(
            sql,
            bind: [.text(ftsExpr), .int(Int64(limit))]
        ) { stmt -> (Decoded, Double) in
            (Self.decodeRow(stmt), -stmt.double(11))
        }

        // Normalize raw scores to [0, 1].
        let keywordScores: [Double]
        if let mx = raw.map(\.1).max(), let mn = raw.map(\.1).min(), mx > mn {
            keywordScores = raw.map { ($0.1 - mn) / (mx - mn) }
        } else {
            keywordScores = raw.map { _ in 1.0 }
        }

        // Build RetrievedChunks. Vector score is 0.0 until sqlite-vec lands on iOS.
        let out: [RetrievedChunk] = zip(raw, keywordScores).map { (pair, kwScore) in
            let d = pair.0
            let hybrid = keywordWeight * kwScore + vectorWeight * 0.0
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
}
