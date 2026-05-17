import Foundation

/// A retrieved content chunk — the unit of knowledge returned by the retriever.
struct Chunk: Identifiable, Hashable {
    let id: String              // chunk_id (e.g., "first-aid.bleeding-control#1")
    let sectionTitle: String
    let text: String
    let domain: String
    let topic: String?
    let hazardLevel: String     // "low" | "medium" | "high" | "critical"
    let tags: [String]
    let sourceTitle: String
    let sourcePublisher: String
    let sourceURL: String?
    let sourceLicense: String

    /// Best-effort short citation label for the chip UI.
    var citationLabel: String {
        if !sourcePublisher.isEmpty { return sourcePublisher }
        if !sourceTitle.isEmpty { return sourceTitle }
        return "Source"
    }
}

/// A search result with score metadata.
struct RetrievedChunk: Identifiable, Hashable {
    let chunk: Chunk
    let score: Double

    var id: String { chunk.id }
}

/// Pack metadata loaded from manifest.yaml.
struct PackManifest: Hashable {
    let id: String
    let version: String
    let displayName: String
    let description: String
    let domains: [String]
    let chunkCount: Int
    let sourceCount: Int
    let createdAt: String?

    /// Display tagline pulled from manifest description.
    var tagline: String {
        let trimmed = description
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed
    }
}

/// A pack installed on device — manifest + filesystem location.
struct InstalledPack: Identifiable, Hashable {
    let manifest: PackManifest
    let rootURL: URL                // dir containing pack.sqlite, etc.
    let packDatabaseURL: URL        // pack.sqlite

    var id: String { manifest.id }
}

/// Listing entry for the catalog — installed or available.
enum PackListing: Identifiable, Hashable {
    case installed(InstalledPack)
    case available(comingSoon: PackPreview)

    var id: String {
        switch self {
        case .installed(let p): return "installed:\(p.id)"
        case .available(let p): return "available:\(p.id)"
        }
    }
}

/// A pack that isn't yet available — used to tease future content.
struct PackPreview: Hashable {
    let id: String
    let displayName: String
    let description: String
    let symbol: String
    let tint: String      // hex string for tint, optional
}
