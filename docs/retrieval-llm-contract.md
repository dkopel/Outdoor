# Retrieval → LLM Contract

**Purpose**: lock down the data shape that passes from the Retriever (Phase 2) to the PromptBuilder (Phase 3) so both agents can build against the same interface without touching each other's code.

The Python reference implementation lives at `pack-builder/src/pack_builder/retriever.py` (`RetrievedChunk` dataclass + `TrailpackReader.query`). The Swift Retriever must produce the same shape; the PromptBuilder consumes it.

---

## The `RetrievedChunk` shape

```python
# Python (pack-builder/src/pack_builder/retriever.py)
@dataclass
class RetrievedChunk:
    chunk_id: str             # e.g. "wildlife.bear-encounter#2"
    section_title: str        # e.g. "If a bear approaches"
    text: str                 # the chunk body (no frontmatter, no headings)
    domain: str               # one of the 12 domain slugs
    hazard_level: str         # "low" | "medium" | "high" | "critical"
    tags: list[str]           # e.g. ["wildlife", "bear", "encounter"]
    source_title: str         # e.g. "Staying Safe Around Bears"
    source_publisher: str     # e.g. "U.S. National Park Service"
    source_url: str           # may be ""
    score_keyword: float      # 0..1 normalized BM25
    score_vector: float       # 0..1 normalized cosine
    score_hybrid: float       # weighted combo, used for ranking
```

```swift
// Swift (app/Outdoor/Core/Retrieval/RetrievedChunk.swift)
public struct RetrievedChunk: Sendable, Hashable {
    public let chunkId: String
    public let sectionTitle: String
    public let text: String
    public let domain: String
    public let hazardLevel: HazardLevel
    public let tags: [String]
    public let sourceTitle: String
    public let sourcePublisher: String
    public let sourceURL: String   // may be empty
    public let scoreKeyword: Double
    public let scoreVector: Double
    public let scoreHybrid: Double
}

public enum HazardLevel: String, Sendable, Codable {
    case low, medium, high, critical
}
```

---

## The query API

### Python (reference)

```python
with TrailpackReader(Path("dist/camping-v1.trailpack")) as r:
    chunks: list[RetrievedChunk] = r.query(
        text="how do I purify water",
        k=5,                 # max chunks returned
        keyword_weight=0.3,
        vector_weight=0.7,
    )
```

### Swift (target)

```swift
public protocol Retriever: Sendable {
    func query(
        _ text: String,
        k: Int,
        keywordWeight: Double,
        vectorWeight: Double
    ) async throws -> [RetrievedChunk]
}
```

Default arguments: `k = 5`, `keywordWeight = 0.3`, `vectorWeight = 0.7`. Phase 3 may override (e.g. `k = 8` if context window allows).

### Empty result behavior

If no chunks match (out-of-pack query), the retriever returns an empty array — **not** `nil` and **not** an error. The PromptBuilder treats `[]` as a signal to return the standard refusal: `"I don't have information on that in your downloaded pack."` and skip the LLM entirely.

---

## Ranking and ordering guarantees

- Returned `[RetrievedChunk]` is **sorted by `scoreHybrid` descending** (highest first).
- `scoreHybrid = keywordWeight * scoreKeyword + vectorWeight * scoreVector`.
- All three scores are in `[0.0, 1.0]`. Higher = better.
- The retriever guarantees **no duplicates** in the result (`chunkId` is unique).

## Score interpretation (for the PromptBuilder)

- `scoreHybrid >= 0.6`: strong match. Include in prompt context.
- `0.4 <= scoreHybrid < 0.6`: weak match. Include but mark as "lower confidence" in the prompt.
- `scoreHybrid < 0.4`: marginal. Phase 3 may choose to drop these from the context or render a "best guess" prefix.
- If all returned chunks have `scoreHybrid < 0.4`, treat as effectively empty (refuse with "low confidence" message).

(These thresholds are tunable in Phase 3; document the final values in `docs/prompt-spec.md`.)

---

## Safety routing (Phase 4 hook)

The Retriever does **not** apply safety routing — it just returns the most relevant chunks. The SafetyRouter (separate component, Phase 4) inspects the query *before* retrieval and may:

- Bypass the LLM entirely and return a locked procedure card
- Inject a safety appendix that the PromptBuilder must include verbatim
- Refuse with a fixed message (e.g. plant edibility questions)

The contract between Retriever and PromptBuilder is unaffected. The SafetyRouter sits *around* this pipeline, not inside it.

---

## Why this matters

- **Phase 2 agent** can build `Retriever` against `[RetrievedChunk]` without knowing what the LLM will do with them.
- **Phase 3 agent** can build `PromptBuilder` against `[RetrievedChunk]` without knowing how SQLite or sqlite-vec is wired underneath.
- The Python `TrailpackReader.query` already produces this shape, so the Python RAG prototype (also Phase 3 work) validates the contract end-to-end **before** any Swift code is written.

---

## Versioning

This is contract v1. Breaking changes require a coordinated update across both Swift Retriever, Swift PromptBuilder, the Python `RetrievedChunk` dataclass, and the iOS PackManager (which records the minimum app version per pack). Add a `contractVersion: 1` field to `manifest.yaml` going forward so installers can refuse incompatible packs.
