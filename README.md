# Outdoor

An offline AI field guide for outdoor adventures. Download knowledge packs before your trip and get expert guidance with zero internet connection.

## Vision

- **Offline-first**: works in airplane mode, deep in the backcountry
- **Knowledge packs**: download topic-specific packs (camping, fishing, hiking)
- **Safe by design**: first aid and safety content uses locked procedures, not freeform AI
- **Cited answers**: every response tied to a source, no hallucinations

## MVP Pack: Outdoor Basics

Covers: first aid, knots, shelter, water purification, fire, navigation, wildlife, plants, weather.

## Stack

- React Native + TypeScript
- On-device LLM (llama.cpp / llama.rn)
- SQLite + FTS5 + vector search
- RAG over offline knowledge packs
