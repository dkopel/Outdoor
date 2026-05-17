"""Hybrid keyword (FTS5) + vector retrieval against a built .trailpack.

This is the CLI demo retriever. The iOS app reimplements equivalent logic in Swift.
"""

from __future__ import annotations

import json
import sqlite3
import tempfile
import zipfile
from dataclasses import dataclass
from pathlib import Path

import numpy as np

from .embedder import EMBEDDING_DIM, embed_one

# Short, very-common words filtered from FTS keyword queries.
# BM25 weights are per-query, so leaving these in inflates scores of
# documents that happen to contain them. Filter them at the query level.
_STOPWORDS = frozenset(
    {
        "a", "an", "the", "and", "or", "but", "if", "of", "to", "in", "on", "at",
        "is", "are", "was", "were", "be", "been", "being",
        "i", "you", "he", "she", "we", "they", "it", "my", "your", "our",
        "do", "does", "did", "will", "would", "should", "could", "can",
        "have", "has", "had", "this", "that", "these", "those",
        "for", "with", "from", "by", "as", "so", "what", "how", "when", "where",
        "why", "who", "which", "see", "get", "got", "go", "going",
        "me", "us", "them", "him", "her", "make", "made", "out", "up", "down",
        "over", "under", "all", "any", "some", "now", "then", "very", "really",
    }
)

# Common multi-word and single-word synonyms — colloquial phrasings users
# type that don't match the canonical terms in the content. Applied as a
# pre-tokenization rewrite: query "epi pen" becomes "epi pen epipen epinephrine".
# Keys are matched as substrings (lowercased); values are added as extra terms.
_SYNONYMS: dict[str, list[str]] = {
    "epi pen": ["epinephrine", "epipen", "auto-injector"],
    "epipen": ["epinephrine", "auto-injector"],
    "broken arm": ["fracture", "splint"],
    "broken leg": ["fracture", "splint"],
    "broken bone": ["fracture", "splint"],
    "broken finger": ["fracture", "splint"],
    "broken rib": ["fracture", "rib"],
    "twisted ankle": ["sprain", "ankle", "RICE"],
    "sprained ankle": ["sprain", "RICE", "ice"],
    "food poisoning": ["diarrhea", "vomiting", "gi", "hydration"],
    "stomach bug": ["diarrhea", "vomiting", "gi", "hydration"],
    "stomach ache": ["diarrhea", "abdominal", "gi"],
    "fire from sticks": ["primitive", "bow drill", "friction"],
    "fire by friction": ["bow drill", "primitive", "spindle"],
    "fire with sticks": ["primitive", "bow drill", "friction"],
    "no lighter": ["primitive", "ferro", "bow drill", "matches"],
    "no matches": ["primitive", "ferro", "lighter"],
    "char cloth": ["tinder", "ferro", "ember"],
    "tinderbox": ["tinder", "char cloth", "ferro"],
    "kid acting": ["altitude", "hypothermia", "dehydration", "child"],
    "child acting": ["altitude", "hypothermia", "dehydration"],
    "set up tent": ["pitch", "tent setup", "stakes"],
    "pitch tent": ["tent setup", "stakes", "guyline"],
    "pitching tent": ["tent setup", "stakes", "guyline"],
    "wading": ["river crossing", "ford", "stream crossing"],
    "ford a stream": ["river crossing", "wading"],
    "wet feet": ["trench foot", "dry socks", "blister"],
    "bug bites": ["mosquito", "tick", "permethrin", "deet"],
    "fog navigation": ["handrail", "compass bearing", "pace"],
    "navigate in fog": ["handrail", "whiteout", "compass bearing", "pace"],
    "in fog": ["handrail", "whiteout", "compass"],
    "how far walked": ["pace count", "naismith", "distance estimation"],
    "how far have we": ["pace count", "naismith", "distance"],
    "how far have we walked": ["pace count", "naismith", "distance"],
    "signal help": ["whistle", "mirror", "PLB", "three"],
    "signal for help": ["whistle", "mirror", "PLB", "three", "signal fire"],
    "kid is acting": ["altitude", "hypothermia", "dehydration", "child"],
    "kid acting weird": ["altitude", "hypothermia", "dehydration", "child"],
    "child is acting": ["altitude", "hypothermia", "dehydration"],
    "acting weird": ["altered mental", "altitude", "hypothermia"],
    "build a campfire": ["teepee", "tinder", "kindling", "lay"],
    "build a fire": ["teepee", "tinder", "kindling", "lay"],
}


def _expand_synonyms(query: str) -> str:
    """Return query plus any expanded synonym terms appended."""
    q = query.lower()
    extras: list[str] = []
    for key, syns in _SYNONYMS.items():
        if key in q:
            extras.extend(syns)
    if extras:
        return query + " " + " ".join(extras)
    return query


def _light_stem(word: str) -> str:
    """Strip common suffixes so 'pitching' matches 'pitch', 'crossings' matches
    'crossing'. Cheap rules; the FTS5 porter tokenizer also stems but it only
    runs on stored terms — our pre-FTS query expansion benefits from this too.
    """
    for suf in ("ings", "ing", "es", "ed", "s"):
        if len(word) > len(suf) + 2 and word.endswith(suf):
            return word[: -len(suf)]
    return word


@dataclass
class RetrievedChunk:
    chunk_id: str
    section_title: str
    text: str
    domain: str
    hazard_level: str
    tags: list[str]
    source_title: str
    source_publisher: str
    source_url: str
    score_keyword: float
    score_vector: float
    score_hybrid: float


class TrailpackReader:
    """Opens a .trailpack and exposes a hybrid-search query interface."""

    def __init__(self, pack_path: Path):
        self._tmp = tempfile.TemporaryDirectory(prefix="trailpack-read-")
        self.root = Path(self._tmp.name)
        with zipfile.ZipFile(pack_path, "r") as zf:
            zf.extractall(self.root)
        self.pack_conn = sqlite3.connect(self.root / "pack.sqlite")
        self.pack_conn.row_factory = sqlite3.Row
        self.vec_conn = sqlite3.connect(self.root / "vectors.sqlite")
        self.vec_conn.row_factory = sqlite3.Row

        # Load all embeddings into memory (fine for <100k chunks).
        rows = self.vec_conn.execute(
            "SELECT chunk_id, vector FROM embeddings"
        ).fetchall()
        self._chunk_ids = [r["chunk_id"] for r in rows]
        if rows:
            self._matrix = np.stack(
                [np.frombuffer(r["vector"], dtype=np.float32) for r in rows]
            )
        else:
            self._matrix = np.zeros((0, EMBEDDING_DIM), dtype=np.float32)

    def close(self) -> None:
        self.pack_conn.close()
        self.vec_conn.close()
        self._tmp.cleanup()

    def __enter__(self) -> "TrailpackReader":
        return self

    def __exit__(self, *exc) -> None:
        self.close()

    def _vector_scores(self, query: str) -> dict[str, float]:
        if self._matrix.size == 0:
            return {}
        q = embed_one(query)
        sims = self._matrix @ q  # already L2-normalized → cosine similarity
        return {self._chunk_ids[i]: float(sims[i]) for i in range(len(self._chunk_ids))}

    def _keyword_scores(self, query: str, limit: int = 50) -> dict[str, float]:
        # 1) Synonym expansion — colloquial phrasings get extra canonical terms.
        # 2) Tokenize + strip stopwords + light-stem.
        # 3) FTS5 MATCH with bm25() weighted so section_title and tags rank
        #    higher than chunk body (titles are short and topical).
        expanded = _expand_synonyms(query)
        raw_terms = expanded.replace('"', "").lower().split()
        cleaned: list[str] = []
        seen: set[str] = set()
        for t in raw_terms:
            if len(t) <= 1 or t in _STOPWORDS:
                continue
            t = "".join(ch for ch in t if ch.isalnum())  # strip punctuation
            if not t or t in seen:
                continue
            seen.add(t)
            cleaned.append(t)
        if not cleaned:
            return {}
        # Build FTS expression — quote each term so they're literals
        # (Porter tokenizer in FTS handles stemming on the indexed side).
        fts_query = " OR ".join(f'"{t}"' for t in cleaned)

        # bm25 column weights match the chunks_fts schema order:
        # (chunk_id, section_title, chunk_text, domain, tags)
        # — chunk_id and domain are UNINDEXED so their weights are skipped
        # in bm25, leaving (section_title, chunk_text, tags).
        rows = self.pack_conn.execute(
            "SELECT chunk_id, bm25(chunks_fts, 4.0, 1.0, 2.0) AS score "
            "FROM chunks_fts WHERE chunks_fts MATCH ? ORDER BY score LIMIT ?",
            (fts_query, limit),
        ).fetchall()
        if not rows:
            return {}
        # bm25() returns lower=better; flip and min-max normalize to [0,1].
        raw = {r["chunk_id"]: -r["score"] for r in rows}

        # 4) File-id boost: if a query term appears in the chunk's file_id
        # (e.g. "tent-setup" matches "tent"), boost that chunk's score. This
        # surfaces topically-named files even when the body text is generic.
        id_rows = self.pack_conn.execute(
            f"SELECT chunk_id, file_id FROM chunks WHERE chunk_id IN "
            f"({','.join(['?'] * len(raw))})",
            list(raw.keys()),
        ).fetchall()
        stems = [_light_stem(t) for t in cleaned]
        for r in id_rows:
            fid = (r["file_id"] or "").lower()
            hits = sum(1 for s in stems if s and s in fid)
            if hits:
                raw[r["chunk_id"]] += hits * 0.5  # half-unit boost per hit

        lo, hi = min(raw.values()), max(raw.values())
        if hi - lo < 1e-9:
            return {k: 1.0 for k in raw}
        return {k: (v - lo) / (hi - lo) for k, v in raw.items()}

    def query(
        self,
        text: str,
        k: int = 5,
        keyword_weight: float = 0.3,
        vector_weight: float = 0.7,
    ) -> list[RetrievedChunk]:
        kw = self._keyword_scores(text)
        vec = self._vector_scores(text)

        # Normalize vector scores from [-1,1] → [0,1]
        vec_norm = {cid: (s + 1.0) / 2.0 for cid, s in vec.items()}

        all_ids = set(kw) | set(vec_norm)
        hybrid: dict[str, tuple[float, float, float]] = {}
        for cid in all_ids:
            k_s = kw.get(cid, 0.0)
            v_s = vec_norm.get(cid, 0.0)
            h = keyword_weight * k_s + vector_weight * v_s
            hybrid[cid] = (k_s, v_s, h)

        top_ids = sorted(hybrid, key=lambda c: hybrid[c][2], reverse=True)[:k]
        if not top_ids:
            return []

        placeholders = ",".join(["?"] * len(top_ids))
        rows = self.pack_conn.execute(
            f"""
            SELECT c.chunk_id, c.section_title, c.chunk_text, c.domain, c.hazard_level,
                   c.tags_json, s.title AS source_title, s.publisher AS source_publisher,
                   s.url AS source_url
            FROM chunks c
            LEFT JOIN sources s ON s.source_key = c.source_key
            WHERE c.chunk_id IN ({placeholders})
            """,
            top_ids,
        ).fetchall()
        by_id = {r["chunk_id"]: r for r in rows}

        out: list[RetrievedChunk] = []
        for cid in top_ids:
            r = by_id.get(cid)
            if not r:
                continue
            k_s, v_s, h = hybrid[cid]
            out.append(
                RetrievedChunk(
                    chunk_id=cid,
                    section_title=r["section_title"] or "",
                    text=r["chunk_text"],
                    domain=r["domain"],
                    hazard_level=r["hazard_level"],
                    tags=json.loads(r["tags_json"]) if r["tags_json"] else [],
                    source_title=r["source_title"] or "",
                    source_publisher=r["source_publisher"] or "",
                    source_url=r["source_url"] or "",
                    score_keyword=k_s,
                    score_vector=v_s,
                    score_hybrid=h,
                )
            )
        return out
