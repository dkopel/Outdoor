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
        let rows = try db.query("SELECT COUNT(*) FROM chunks") { stmt in
            Int(stmt.int(0))
        }
        return rows.first ?? 0
    }

    func sourceCount() throws -> Int {
        let rows = try db.query("SELECT COUNT(*) FROM sources") { stmt in
            Int(stmt.int(0))
        }
        return rows.first ?? 0
    }

    func availableDomains() throws -> [String] {
        try db.query(
            "SELECT DISTINCT domain FROM chunks ORDER BY domain"
        ) { stmt in
            stmt.text(0)
        }
    }

    // MARK: - Browse by domain

    /// Return one representative chunk per file in the domain (the first section)
    /// for use in the "Guide → domain" list view.
    func topicsInDomain(_ domain: String) throws -> [Chunk] {
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
            try decodeChunk(stmt)
        }
    }

    func chunk(byID id: String) throws -> Chunk? {
        let sql = """
        SELECT c.chunk_id, c.section_title, c.chunk_text, c.domain, c.topic,
               c.hazard_level, c.tags_json,
               s.title, s.publisher, s.url, s.license
        FROM chunks c
        LEFT JOIN sources s ON s.source_key = c.source_key
        WHERE c.chunk_id = ?
        """
        let rows = try db.query(sql, bind: [.text(id)]) { stmt in
            try decodeChunk(stmt)
        }
        return rows.first
    }

    // MARK: - Search (FTS5 keyword retrieval)

    /// Hybrid retrieval, v1: pure FTS5 keyword search using BM25 scoring.
    /// Stopwords are filtered before forming the FTS query so common words
    /// like "the" / "I" don't dominate ranking.
    ///
    /// Phase 3 will layer vector similarity on top; the API shape stays the same.
    func search(_ query: String, limit: Int = 8) throws -> [RetrievedChunk] {
        let terms = Self.tokenize(query)
        guard !terms.isEmpty else { return [] }

        // Quote each term so FTS treats them as bareword tokens, OR-joined.
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

        // bm25 returns lower=better; flip sign so higher=better, then normalize.
        var rows = try db.query(
            sql,
            bind: [.text(ftsExpr), .int(Int64(limit))]
        ) { stmt -> (Chunk, Double) in
            let chunk = try decodeChunk(stmt)
            let bm25 = stmt.double(11)
            return (chunk, -bm25)
        }

        // Normalize raw scores to [0, 1] for a stable UI display.
        if let max = rows.map(\.1).max(), let min = rows.map(\.1).min(), max > min {
            rows = rows.map { ($0.0, ($0.1 - min) / (max - min)) }
        } else {
            rows = rows.map { ($0.0, 1.0) }
        }

        return rows.map { RetrievedChunk(chunk: $0.0, score: $0.1) }
    }

    // MARK: - Internals

    private func decodeChunk(_ stmt: Statement) throws -> Chunk {
        let tagsJSON = stmt.text(6)
        let tags: [String] = {
            guard let data = tagsJSON.data(using: .utf8),
                  let arr = try? JSONSerialization.jsonObject(with: data) as? [String]
            else { return [] }
            return arr
        }()
        return Chunk(
            id: stmt.text(0),
            sectionTitle: stmt.text(1),
            text: stmt.text(2),
            domain: stmt.text(3),
            topic: stmt.textOrNil(4),
            hazardLevel: stmt.text(5),
            tags: tags,
            sourceTitle: stmt.textOrNil(7) ?? "",
            sourcePublisher: stmt.textOrNil(8) ?? "",
            sourceURL: stmt.textOrNil(9),
            sourceLicense: stmt.textOrNil(10) ?? ""
        )
    }

    // Very-common English words filtered before FTS to keep BM25 useful.
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
