# Outdoor

An offline AI field guide for outdoor adventures. Download a knowledge pack before your trip, then ask questions in airplane mode — no signal needed.

## Status

🚧 Phase 0 — building the pack pipeline + camping pack content. iOS app in Phase 2.

## Vision

> "Answer based on your downloaded pack" — not "AI knows this."

- **Offline-first**: works in airplane mode, deep in the backcountry
- **Pack-based**: download what you need (camping first; hiking, fishing, regional packs later)
- **Safe by design**: first aid + edible plants use locked procedures, never freeform LLM
- **Cited**: every answer tied to a source chunk

## v1 Scope

- iOS (SwiftUI, iPhone 14+)
- One pack: **Camping** — first aid, knots, water, shelter, fire, navigation, wildlife, plants, weather, food, gear repair, trip basics
- On-device LLM (MLX-Swift + Llama 3.2 3B Q4)
- Hybrid retrieval: SQLite FTS5 + sqlite-vec

## Monorepo Layout

```
pack-builder/   Python CLI: ingests Markdown content → .trailpack
packs/camping/  Authored content + safety rules + manifest
app/            iOS app (added in Phase 2)
evals/          Test questions + safety red-team set
docs/           Plan, content style guide, safety spec
dist/           Built .trailpack files (gitignored)
```

## Quickstart (Phase 1 — pack builder)

```bash
cd pack-builder
python -m venv .venv && source .venv/bin/activate
pip install -e .

# Build the camping pack
pack-builder build ../packs/camping --out ../dist/camping-v1.trailpack

# Run a query against the built pack
pack-builder query "how do I purify water?" --pack ../dist/camping-v1.trailpack
```

See [`docs/plan.md`](docs/plan.md) for the full build plan.

## License

TBD. Content sources tracked individually in `packs/*/manifest.yaml` and `pack.sqlite`.
