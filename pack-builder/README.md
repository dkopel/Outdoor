# pack-builder

Python CLI that compiles a directory of authored Markdown content into a `.trailpack` file consumed by the Outdoor mobile app.

## What it does

1. **Load** — reads `.md` files with YAML frontmatter from a pack source dir
2. **Validate** — checks frontmatter, manifest, and safety rules against schemas
3. **Chunk** — splits each file by `##` headings, one chunk per section
4. **Embed** — generates 384-dim embeddings with `all-MiniLM-L6-v2`
5. **Package** — writes `pack.sqlite` (FTS5) + `vectors.sqlite` (sqlite-vec via Python rows) + manifest + safety rules into a signed ZIP

## Install

```bash
cd pack-builder
python -m venv .venv && source .venv/bin/activate
pip install -e .
```

First run downloads the embedding model (~80 MB) into the HuggingFace cache.

## Commands

```bash
# Validate a pack source directory
pack-builder validate ../packs/camping

# Build a .trailpack
pack-builder build ../packs/camping --out ../dist/camping-v1.trailpack

# Query a built pack (CLI demo — retrieval only, no LLM)
pack-builder query "how do I purify water?" --pack ../dist/camping-v1.trailpack

# Inspect a built pack (manifest, chunk count, domains)
pack-builder inspect ../dist/camping-v1.trailpack
```

## Notes

- **Vector store**: this Python build pipeline stores embeddings as raw float32 BLOBs in a SQLite table — the iOS app will read these and load them into `sqlite-vec`'s `vec0` virtual table at install time. (Building with `sqlite-vec` directly from Python adds a native dependency we don't need for the build side.)
- **No LLM in this CLI** — `query` only does retrieval and prints chunks with citations. The mobile app handles LLM synthesis.
