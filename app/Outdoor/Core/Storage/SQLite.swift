import Foundation
import SQLite3

/// Minimal SQLite wrapper around the system `libsqlite3`.
///
/// Read-only by default — packs are bundled artifacts, not user data.
/// Supports parameterized queries, row decoding, and FTS5 (which iOS's
/// system SQLite ships with by default).
final class SQLiteDB {

    enum DBError: Error, CustomStringConvertible {
        case openFailed(String)
        case prepareFailed(String)
        case stepFailed(String)
        case bindFailed(String)

        var description: String {
            switch self {
            case .openFailed(let m):    return "SQLite open failed: \(m)"
            case .prepareFailed(let m): return "SQLite prepare failed: \(m)"
            case .stepFailed(let m):    return "SQLite step failed: \(m)"
            case .bindFailed(let m):    return "SQLite bind failed: \(m)"
            }
        }
    }

    enum Value {
        case int(Int64)
        case double(Double)
        case text(String)
        case null
    }

    private var handle: OpaquePointer?
    let path: String

    init(path: String, readOnly: Bool = true) throws {
        self.path = path
        let flags = readOnly
            ? (SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX)
            : (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_NOMUTEX)
        if sqlite3_open_v2(path, &handle, flags, nil) != SQLITE_OK {
            let msg = handle.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown"
            sqlite3_close(handle)
            throw DBError.openFailed(msg)
        }
    }

    deinit {
        if let handle { sqlite3_close(handle) }
    }

    /// Execute a query, decoding each row through `decode`. Returns all rows.
    func query<T>(_ sql: String,
                  bind params: [Value] = [],
                  decode: (Statement) throws -> T) throws -> [T] {
        let stmt = try Statement(db: self, sql: sql)
        defer { stmt.finalize() }
        try stmt.bind(params)
        var out: [T] = []
        while try stmt.step() {
            out.append(try decode(stmt))
        }
        return out
    }

    fileprivate var rawHandle: OpaquePointer? { handle }
}

/// Prepared statement wrapper.
final class Statement {
    fileprivate var stmt: OpaquePointer?
    private weak var db: SQLiteDB?

    fileprivate init(db: SQLiteDB, sql: String) throws {
        self.db = db
        guard sqlite3_prepare_v2(db.rawHandle, sql, -1, &stmt, nil) == SQLITE_OK else {
            let msg = db.rawHandle.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown"
            throw SQLiteDB.DBError.prepareFailed("\(msg) — sql: \(sql.prefix(100))")
        }
    }

    fileprivate func bind(_ params: [SQLiteDB.Value]) throws {
        for (i, v) in params.enumerated() {
            let index = Int32(i + 1)
            let rc: Int32
            switch v {
            case .int(let n):    rc = sqlite3_bind_int64(stmt, index, n)
            case .double(let d): rc = sqlite3_bind_double(stmt, index, d)
            case .text(let s):
                // SQLITE_TRANSIENT = -1, tells SQLite to copy the string
                let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
                rc = sqlite3_bind_text(stmt, index, s, -1, transient)
            case .null:          rc = sqlite3_bind_null(stmt, index)
            }
            if rc != SQLITE_OK {
                throw SQLiteDB.DBError.bindFailed("param \(index)")
            }
        }
    }

    fileprivate func step() throws -> Bool {
        let rc = sqlite3_step(stmt)
        if rc == SQLITE_ROW { return true }
        if rc == SQLITE_DONE { return false }
        let msg = db?.rawHandle.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown"
        throw SQLiteDB.DBError.stepFailed(msg)
    }

    fileprivate func finalize() {
        sqlite3_finalize(stmt)
    }

    // MARK: Column readers — used in row decoders

    func int(_ col: Int) -> Int64 {
        sqlite3_column_int64(stmt, Int32(col))
    }

    func double(_ col: Int) -> Double {
        sqlite3_column_double(stmt, Int32(col))
    }

    func text(_ col: Int) -> String {
        guard let cstr = sqlite3_column_text(stmt, Int32(col)) else { return "" }
        return String(cString: cstr)
    }

    func textOrNil(_ col: Int) -> String? {
        if sqlite3_column_type(stmt, Int32(col)) == SQLITE_NULL { return nil }
        return text(col)
    }
}
