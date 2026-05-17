"""Compile loaded pack source into a .trailpack ZIP.

Outputs inside the ZIP:
    manifest.yaml
    safety_rules.yaml
    pack.sqlite             # chunks + FTS5 index + sources
    vectors.sqlite          # embeddings as float32 BLOBs (vec0-loadable on device)
    licenses.json
    media/                  # copied from source if present
"""

from __future__ import annotations

import hashlib
import json
import shutil
import sqlite3
import tempfile
import zipfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import numpy as np
import yaml

from .chunker import Chunk, chunk_files
from .embedder import EMBEDDING_DIM, embed_texts
from .loader import PackSource


def _init_pack_sqlite(db_path: Path) -> sqlite3.Connection:
    conn = sqlite3.connect(db_path)
    conn.executescript(
        """
        PRAGMA journal_mode = WAL;
        PRAGMA synchronous = NORMAL;

        CREATE TABLE sources (
            source_key TEXT PRIMARY KEY,
            title TEXT,
            publisher TEXT,
            url TEXT,
            license TEXT,
            retrieved_at TEXT,
            notes TEXT
        );

        CREATE TABLE chunks (
            chunk_id TEXT PRIMARY KEY,
            file_id TEXT NOT NULL,
            section_index INTEGER NOT NULL,
            section_title TEXT,
            domain TEXT NOT NULL,
            topic TEXT,
            subtopic TEXT,
            hazard_level TEXT NOT NULL,
            tags_json TEXT NOT NULL,
            chunk_text TEXT NOT NULL,
            source_key TEXT NOT NULL,
            FOREIGN KEY (source_key) REFERENCES sources(source_key)
        );

        CREATE INDEX idx_chunks_domain ON chunks(domain);
        CREATE INDEX idx_chunks_hazard ON chunks(hazard_level);

        CREATE VIRTUAL TABLE chunks_fts USING fts5(
            chunk_id UNINDEXED,
            section_title,
            chunk_text,
            domain UNINDEXED,
            tags,
            tokenize = "porter unicode61"
        );
        """
    )
    return conn


def _init_vectors_sqlite(db_path: Path) -> sqlite3.Connection:
    """Store embeddings as a simple table on the build side.

    The iOS app loads this into sqlite-vec's vec0 virtual table at install time.
    Keeping the build output portable avoids needing sqlite-vec installed during build.
    """
    conn = sqlite3.connect(db_path)
    conn.executescript(
        """
        PRAGMA journal_mode = WAL;

        CREATE TABLE embeddings (
            chunk_id TEXT PRIMARY KEY,
            dim INTEGER NOT NULL,
            vector BLOB NOT NULL
        );

        CREATE TABLE meta (
            key TEXT PRIMARY KEY,
            value TEXT
        );
        """
    )
    conn.execute(
        "INSERT INTO meta(key, value) VALUES (?, ?)", ("embedding_dim", str(EMBEDDING_DIM))
    )
    conn.commit()
    return conn


def _collect_sources(source: PackSource) -> dict[str, dict[str, Any]]:
    """Walk all content files and produce a deduped {source_key: source_dict}."""
    from .chunker import _source_key

    out: dict[str, dict[str, Any]] = {}
    for cf in source.content_files:
        src = cf.frontmatter.get("source") or {}
        if not src:
            continue
        key = _source_key(src)
        if key not in out:
            out[key] = src
    return out


def _write_chunks(conn: sqlite3.Connection, chunks: list[Chunk]) -> None:
    rows = [
        (
            c.chunk_id,
            c.file_id,
            c.section_index,
            c.section_title,
            c.domain,
            c.topic,
            c.subtopic,
            c.hazard_level,
            json.dumps(c.tags),
            c.text,
            c.source_key,
        )
        for c in chunks
    ]
    conn.executemany(
        """
        INSERT INTO chunks
            (chunk_id, file_id, section_index, section_title, domain, topic,
             subtopic, hazard_level, tags_json, chunk_text, source_key)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        rows,
    )

    fts_rows = [
        (c.chunk_id, c.section_title, c.text, c.domain, " ".join(c.tags))
        for c in chunks
    ]
    conn.executemany(
        "INSERT INTO chunks_fts(chunk_id, section_title, chunk_text, domain, tags) "
        "VALUES (?, ?, ?, ?, ?)",
        fts_rows,
    )
    conn.commit()


def _write_sources(conn: sqlite3.Connection, sources: dict[str, dict[str, Any]]) -> None:
    rows = []
    for key, s in sources.items():
        rows.append(
            (
                key,
                s.get("title", ""),
                s.get("publisher", ""),
                s.get("url", ""),
                s.get("license", "author"),
                str(s.get("retrieved_at", "")),
                s.get("notes", ""),
            )
        )
    conn.executemany(
        """
        INSERT INTO sources(source_key, title, publisher, url, license, retrieved_at, notes)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        rows,
    )
    conn.commit()


def _write_embeddings(
    conn: sqlite3.Connection, chunks: list[Chunk], vectors: np.ndarray
) -> None:
    rows = [
        (c.chunk_id, EMBEDDING_DIM, vectors[i].tobytes())
        for i, c in enumerate(chunks)
    ]
    conn.executemany(
        "INSERT INTO embeddings(chunk_id, dim, vector) VALUES (?, ?, ?)", rows
    )
    conn.commit()


def _sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for blk in iter(lambda: f.read(64 * 1024), b""):
            h.update(blk)
    return h.hexdigest()


def build_pack(source: PackSource, out_path: Path, embed: bool = True) -> dict[str, Any]:
    """Build a .trailpack ZIP. Returns the final manifest with computed hashes."""
    chunks = chunk_files(source.content_files)
    sources_map = _collect_sources(source)

    with tempfile.TemporaryDirectory(prefix="trailpack-build-") as tmpd:
        tmp = Path(tmpd)

        # 1. pack.sqlite
        pack_db = tmp / "pack.sqlite"
        conn = _init_pack_sqlite(pack_db)
        _write_sources(conn, sources_map)
        _write_chunks(conn, chunks)
        conn.close()

        # 2. vectors.sqlite
        vec_db = tmp / "vectors.sqlite"
        vconn = _init_vectors_sqlite(vec_db)
        if embed and chunks:
            vectors = embed_texts([c.text for c in chunks])
            _write_embeddings(vconn, chunks, vectors)
        vconn.close()

        # 3. safety_rules.yaml + manifest.yaml + licenses.json
        (tmp / "safety_rules.yaml").write_text(
            yaml.safe_dump(source.safety_rules, sort_keys=False), encoding="utf-8"
        )

        licenses = {
            key: {
                "title": s.get("title"),
                "publisher": s.get("publisher"),
                "url": s.get("url"),
                "license": s.get("license"),
            }
            for key, s in sources_map.items()
        }
        (tmp / "licenses.json").write_text(json.dumps(licenses, indent=2), encoding="utf-8")

        # 4. media/
        media_src = source.root / "media"
        if media_src.exists():
            shutil.copytree(media_src, tmp / "media")

        # 5. manifest.yaml — assemble with computed values
        built_manifest = dict(source.manifest)
        built_manifest["chunk_count"] = len(chunks)
        built_manifest["source_count"] = len(sources_map)
        built_manifest["created_at"] = datetime.now(timezone.utc).isoformat(timespec="seconds")
        built_manifest.setdefault("embeddings", {})
        built_manifest["embeddings"]["model"] = "all-MiniLM-L6-v2"
        built_manifest["embeddings"]["dim"] = EMBEDDING_DIM

        hashes = {
            "pack.sqlite": _sha256(pack_db),
            "vectors.sqlite": _sha256(vec_db),
        }
        if (tmp / "safety_rules.yaml").exists():
            hashes["safety_rules.yaml"] = _sha256(tmp / "safety_rules.yaml")
        built_manifest["hashes"] = hashes

        manifest_path = tmp / "manifest.yaml"
        manifest_path.write_text(
            yaml.safe_dump(built_manifest, sort_keys=False), encoding="utf-8"
        )

        # 6. ZIP everything
        out_path.parent.mkdir(parents=True, exist_ok=True)
        if out_path.exists():
            out_path.unlink()
        with zipfile.ZipFile(out_path, "w", zipfile.ZIP_DEFLATED) as zf:
            for p in sorted(tmp.rglob("*")):
                if p.is_file():
                    zf.write(p, p.relative_to(tmp))

        built_manifest["size_bytes"] = out_path.stat().st_size
        return built_manifest
