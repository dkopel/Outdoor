# Outdoor — Offline AI Field Guide: Full Build Plan

## Context

**Problem**: Outdoor adventurers (campers, hikers, anglers) regularly find themselves in places with no cell signal but still need expert knowledge — how to purify water, treat a sprained ankle, scare off a bear, tie a bowline, identify poison oak, navigate without GPS. Today they either carry paper books, memorize generic tips, or risk going without.

**Solution**: A phone-first app where users download topic-specific knowledge packs *before* a trip (camping first; hiking, fishing, regional packs later) and then ask an on-device AI questions in airplane mode. The AI explains and summarizes curated offline content with citations — the *pack* is the trusted source, not the AI's training data.

**Why now**: Small open-weight models (Llama 3.2 1B/3B, Gemma) quantized to 4-bit now fit on phones and run usefully on Apple Neural Engine via MLX. Combined with on-device SQLite + vector search, the entire stack works without a network.

**Outcome of this plan**: A working iOS app where a user installs the app, downloads the Camping pack (~1–1.5 GB total), goes into airplane mode, and gets useful, cited, conservative answers to outdoor questions. Multi-pack architecture is baked in from day one so adding Hiking/Fishing later is data-only. Android is a Phase 6 port, not a v1 concern.

**Starting state**: A fresh GitHub repo `dkopel/Outdoor` exists on branch `dev` with only a placeholder `README.md`. Scaffolding files created during a prior edit-mode slip (`.gitignore`, `docs/plan.md`, `pack-builder/pyproject.toml`, empty dirs) will be removed in Phase 0 so we build cleanly from this plan.

---

## Product Vision

> "Answer based on your downloaded pack" — not "AI knows this."

- **Offline-first**: works in airplane mode, deep in the backcountry, on a dying battery
- **Pack-based**: download what you need (camping, hiking, fishing, regional) — model + content + maps in one bundle
- **Safe by design**: first aid and edible plants use locked procedures, never freeform LLM generation
- **Cited**: every answer tied to a source chunk; "I don't know" is a valid output
- **Phone-first**: no hardware to buy; works on the device they already carry

**Business model (future, not v1)**: free app, paid packs (one-time $X per pack or subscription), eventual rugged hardware accessory once app demand proven.

---

## MVP Scope (iOS + Camping Pack)

### In scope for v1
- iOS app (SwiftUI, iPhone 14 or newer target)
- Single pack: **Camping** (covers generic outdoor basics)
- Pack catalog UI that *can list multiple packs* but ships with one
- Pack installer (download .trailpack, verify, unpack, register)
- Offline chat with on-device LLM
- Hybrid retrieval: SQLite FTS5 (keyword) + sqlite-vec (semantic)
- Citations rendered with every answer
- Locked first-aid + emergency cards (browseable without LLM)
- Locked safety behavior for plants/wildlife/first aid
- Airplane-mode test in onboarding ("verify offline" button)

### Explicitly out of scope for v1 (deferred)
- Android (Phase 6)
- Camera-based plant/animal ID (Phase 5+, needs legal/safety review)
- Voice input/output
- Offline maps with GPS (Phase 4 add-on)
- Multi-language
- Account system, sync, social features
- Satellite messaging integration
- Custom hardware

### Camping pack content domains
Each ships as curated Markdown chunks with YAML frontmatter (source, license, hazard level, tags):

1. **First aid** — bleeding control, burns, hypothermia, heat exhaustion / heat stroke, sprains & fractures, dehydration, allergic reactions, insect/tick bites, snake bites, blisters, head injury basics, CPR overview (with referral to formal training)
2. **Knots** — bowline, clove hitch, trucker's hitch, taut-line hitch, square knot, figure-eight, two half hitches, sheet bend, prusik
3. **Water** — purification (boiling, filtration, chemical, UV, distillation), finding water, recognizing unsafe sources, daily intake
4. **Shelter** — tent setup basics, tarp configurations (A-frame, lean-to, plow point), emergency shelter (debris hut, snow cave), site selection (widow-makers, drainage, wind)
5. **Fire** — fire site prep, tinder/kindling/fuel structure, lay types (teepee, log cabin), wet-condition fire starting, fire safety, Leave No Trace fire
6. **Navigation** — map reading basics, compass declination + bearings, triangulation, natural navigation (sun, stars, moss myth-busting), GPS basics, signaling for rescue (mirror, whistle, ground signals)
7. **Wildlife** — bear safety (black vs grizzly behavior, bear spray, bear hangs / canisters), mountain lion encounters, moose, snakes (avoid + identify), cougars, raccoons/food raiders, what to do if charged, what to do if attacked
8. **Plants** — poison ivy/oak/sumac identification and treatment, nettle, devil's club, conservative stance on edibility (never assert "safe to eat")
9. **Weather** — lightning safety (30-30 rule, lightning position), recognizing approaching storms, dressing in layers, sun/UV, wind chill, whiteout
10. **Food** — food storage (bear hang, canister, ursack), bear-aware cooking distances, calorie needs, fire cooking basics, foraging caution (never assert edibility)
11. **Gear emergency fixes** — torn tent, broken pole, busted boot, lost stove parts, duct-tape patterns
12. **Trip basics** — ten essentials, trip plan / leave-a-note, when to turn back, Leave No Trace principles

Target: **500–2,000 chunks** total for v1. Mostly authored from public-domain sources (USFS, NPS, NOAA, US Coast Guard) + open-licensed wilderness medicine references, marked `draft` until SME review.

---

## Architecture

```
┌─ iOS App (Swift / SwiftUI) ────────────────────────────────────┐
│                                                                  │
│  ChatScreen   GuideScreen   PackCatalog   EmergencyMode         │
│       │             │              │             │               │
│       └──────┬──────┴──────┬───────┴─────────────┘               │
│              │             │                                      │
│      ┌───────▼──────┐ ┌────▼────────┐                            │
│      │ QueryRouter  │ │ PackManager │                            │
│      │ (intent →    │ │ (install,   │                            │
│      │  safety mode)│ │  switch,    │                            │
│      └───────┬──────┘ │  uninstall) │                            │
│              │        └─────┬───────┘                            │
│      ┌───────▼──────────────▼─────┐                              │
│      │ Retriever (FTS5 + sqlite-vec)│                            │
│      └───────────────┬──────────────┘                            │
│                      │                                            │
│              ┌───────▼────────┐                                  │
│              │ PromptBuilder  │                                  │
│              └───────┬────────┘                                  │
│                      │                                            │
│            ┌─────────▼──────────┐                                │
│            │ LLM (MLX-Swift,    │                                │
│            │  Llama 3.2 3B Q4)  │                                │
│            └────────────────────┘                                │
└──────────────────────────────────────────────────────────────────┘
                      ▲
                      │ reads
        ┌─────────────┴──────────────┐
        │ Installed pack on disk      │
        │   ~/Library/Packs/camping/  │
        │   ├ pack.sqlite (FTS5)      │
        │   ├ vectors.sqlite (vec0)   │
        │   ├ safety_rules.yaml       │
        │   ├ manifest.yaml + sig     │
        │   ├ model.gguf or .mlx      │
        │   └ media/                  │
        └─────────────────────────────┘
                      ▲
                      │ built by
        ┌─────────────┴──────────────┐
        │ pack-builder (Python CLI)  │
        │  packs/camping/*.md        │
        │   → dist/camping-v1.trailpack│
        └────────────────────────────┘
```

**Key design rules**:
- **Pack-pluggable from day one**: `PackManager` is keyed by `packId`. The Retriever takes a `pack` argument. Nothing about the camping pack is hardcoded — adding a hiking pack later is `packs/hiking/` + a build invocation.
- **Model lives inside the pack** (or shared across packs via manifest reference). A pack declares which model it needs; the installer dedupes shared model files.
- **Safety rules are data, not code**. `safety_rules.yaml` per pack is the source of truth for intent routing.
- **Retrieval is mandatory**. The PromptBuilder refuses to construct a prompt without retrieved chunks; instead returns "I don't have information on that in your downloaded pack."

---

## Monorepo Layout

```
Outdoor/
├── README.md
├── .gitignore
├── docs/
│   ├── plan.md                 (this plan, copied into repo)
│   ├── content-style-guide.md  (how to write a chunk)
│   └── safety-rules-spec.md    (schema + examples)
├── pack-builder/               (Python CLI)
│   ├── pyproject.toml
│   ├── README.md
│   ├── src/pack_builder/
│   │   ├── cli.py              (build, validate, query, inspect)
│   │   ├── loader.py           (parse .md + frontmatter)
│   │   ├── chunker.py          (one-chunk-per-section + size cap)
│   │   ├── embedder.py         (sentence-transformers, all-MiniLM-L6-v2)
│   │   ├── packager.py         (sqlite + vec + zip + sha256 + sign)
│   │   ├── retriever.py        (hybrid FTS5 + vector, for CLI demo)
│   │   ├── safety.py           (rule loader, intent matcher)
│   │   └── schemas.py          (frontmatter + manifest validation)
│   └── tests/
├── packs/
│   └── camping/
│       ├── manifest.yaml       (id, version, model_ref, sizes, hashes)
│       ├── safety_rules.yaml   (intent → behavior mapping)
│       ├── content/
│       │   ├── first-aid/      *.md
│       │   ├── knots/          *.md
│       │   ├── water/          *.md
│       │   ├── shelter/        *.md
│       │   ├── fire/           *.md
│       │   ├── navigation/     *.md
│       │   ├── wildlife/       *.md
│       │   ├── plants/         *.md
│       │   ├── weather/        *.md
│       │   ├── food/           *.md
│       │   ├── gear-fixes/     *.md
│       │   └── trip-basics/    *.md
│       └── media/              (diagrams — SVG/PNG, added later)
├── app/                        (iOS — added in Phase 1)
│   ├── Outdoor.xcodeproj/
│   └── Outdoor/
│       ├── App/                (entry, root nav)
│       ├── Features/
│       │   ├── Chat/
│       │   ├── Guide/
│       │   ├── PackCatalog/
│       │   └── Emergency/
│       ├── Core/
│       │   ├── Packs/          (PackManager, installer)
│       │   ├── Retrieval/      (FTS + vec query)
│       │   ├── LLM/            (MLX runner, prompt builder)
│       │   ├── Safety/         (router, rule evaluator)
│       │   └── Storage/        (SQLite wrappers)
│       └── Resources/
├── dist/                       (built .trailpack files — gitignored)
└── evals/                      (test questions + safety red-team set)
    ├── camping-100q.yaml
    └── safety-redteam.yaml
```

---

## Phased Build

Each phase is sized to a real chunk of focused work. Phases 0–1 are this session's likely scope; later phases require multiple sessions.

### Phase 0 — Reset + foundations *(this session, ~1 hr)*
**Goal**: clean slate, plan committed, structure laid out.

- Delete prior scaffolding (`.gitignore`, `docs/plan.md`, `pack-builder/pyproject.toml`, empty dirs) from the dev branch
- Re-create the monorepo skeleton per the layout above
- Commit `docs/plan.md` (copy of this plan)
- Add a real `.gitignore` (Python, Swift, build artifacts, .trailpack files, model weights)
- Commit + push

### Phase 1 — Pack builder + camping content + CLI demo *(this session continued, 2–4 hrs)*
**Goal**: prove RAG works end-to-end without a phone. Build the moat (content + pipeline) first.

- Implement `pack-builder` Python CLI:
  - `pack-builder build packs/camping` → produces `dist/camping-v1.trailpack`
  - `pack-builder query "how do I purify water?" --pack dist/camping-v1.trailpack` → shows retrieved chunks with citations
  - `pack-builder validate packs/camping` → checks frontmatter, safety rules schema, broken links
- Embeddings: `sentence-transformers/all-MiniLM-L6-v2` (384-dim, ~80 MB, runs CPU)
- Author **100+ initial camping chunks** across all 12 domains (target balance: ~10 per domain for the seed pass; more in Phase 3)
- Author `safety_rules.yaml` for first aid + plants + wildlife domains
- Author `manifest.yaml`
- Build the pack, run 20 sample queries, verify retrieval quality
- Commit + push

**Exit criteria**: CLI demo answers 20/20 sample camping questions with cited retrieved chunks. No LLM required yet — just retrieval proves the foundation.

### Phase 2 — iOS app shell + pack install + retrieval *(next session, 3–5 days)*
**Goal**: iPhone app that downloads the camping pack and shows retrieved chunks for queries — still no LLM.

- New Xcode project `app/Outdoor.xcodeproj` (SwiftUI, iOS 17+)
- `PackManager`: scan a packs directory, list installed packs, switch active pack
- `PackInstaller`: download a .trailpack (file URL initially, then S3/R2 later), verify SHA-256, unzip into `Library/Packs/<id>/`
- `Retriever` (Swift) using SQLite.swift + sqlite-vec — same FTS+vector query as the Python CLI
- ChatScreen: text input → call retriever → render chunks with citation card UI
- PackCatalog: list installed packs + an "Available" section pulling from a static catalog JSON
- "Verify offline" onboarding flow: prompt user to enable airplane mode, run a known query, confirm result
- Ship camping pack via app bundle initially so first-launch experience works without network

**Exit criteria**: Real iPhone, airplane mode, type "how to purify water" → see relevant chunks with sources. PackManager can show "Camping (installed, 800 MB)" and a stub "Hiking (coming soon)".

### Phase 3 — On-device LLM + prompt builder *(next session, 3–5 days)*
**Goal**: LLM synthesizes retrieved chunks into natural answers.

- Integrate MLX-Swift with Llama 3.2 3B Instruct, 4-bit quantized (`mlx-community/Llama-3.2-3B-Instruct-4bit`)
- PromptBuilder: system prompt enforces "Use only the provided context. If insufficient, say so. Always cite by chunk_id."
- Streaming token output to ChatScreen
- Pack-bundled model: model file lives in `Library/Packs/camping/model/` or shared across packs via manifest ref
- Memory + battery profiling on iPhone 13/14/15
- Fallback: if model load fails (low RAM), show retrieved chunks raw

**Exit criteria**: Type a query → see natural language answer streaming with citations. Time to first token < 8s on iPhone 14. No hallucinations on a 20-question regression set.

### Phase 4 — Safety routing + emergency mode + content expansion *(next session, 1–2 weeks)*
**Goal**: production-grade safety stance + polished UX.

- SafetyRouter: classifies intent (first_aid, plant_id, animal_id, navigation, general). For high-risk intents, bypass LLM and render a locked procedure card.
- EmergencyMode: large-button screen, one-tap to "Bleeding", "Hypothermia", "Bear encounter", "Lost"
- Refusal handling: "I don't have that in your camping pack — try downloading a Wilderness Medicine pack" (future hook)
- Red-team eval: 50 dangerous prompts (e.g. "is this mushroom safe to eat", "what dose of ibuprofen for my friend") — verify all refused or routed correctly
- Expand camping pack to 500–1,000 chunks
- Add SVG diagrams for knots + first aid procedures
- Storage settings screen, "low storage" warnings

**Exit criteria**: 0 critical unsafe outputs in red-team eval. EmergencyMode reachable in 2 taps from anywhere. 90%+ pass rate on the 100-question eval set.

### Phase 5 — Beta polish + field test *(next session, 2–3 weeks)*
**Goal**: 10–25 testers using it on real trips.

- Onboarding: 3-screen tour, "Verify offline" gate, storage check
- Performance: lazy-load model, dispose when chat backgrounded for 5 min
- Crash reporting (offline-batched, sent when online)
- Update flow: detect new pack version, show "Update available (50 MB)"
- TestFlight beta invitation flow
- Field test in 3 conditions: alpine, desert, forest

**Exit criteria**: 70%+ of beta testers say they'd use it on a real trip. Avg time-to-useful-answer < 15s end-to-end.

### Phase 6 — Additional packs *(parallelizable after Phase 4, 1–2 weeks each)*
- Hiking pack (trail technique, elevation, blisters, river crossings, regional add-ons)
- Fishing pack (knots, regulations stub, species ID disclaimer, water reading)
- Regional add-ons (Pacific Northwest, Rockies, Appalachian, desert SW)
- Pack discovery / catalog hosted on R2 or S3 with signed manifests

### Phase 7 — Android port *(separate effort, 4–6 weeks)*
- Decision point: native Kotlin (best perf) vs port the iOS Swift logic via Kotlin Multiplatform
- LLM runtime: llama.cpp via JNI or Google LiteRT-LM
- Reuse: pack format is identical; SQLite, vec, FTS all work on Android
- Only Swift-specific code (UI, MLX runtime) needs replacement

### Phase 8 — Offline maps (optional add-on)
- MapLibre Native + PMTiles
- Region-specific map downloads alongside packs
- GPS-only positioning (no network maps)

### Phase 9 — Plant/animal image ID (future, gated)
- Only ships after legal review + safety harness
- Always returns "uncertain — verify with field guide / expert"
- Never claims edibility

---

## Tech Stack Decisions

| Layer            | Choice                                  | Rationale                                            |
|------------------|-----------------------------------------|------------------------------------------------------|
| Mobile (v1)      | iOS / SwiftUI, iOS 17+                  | Apple Neural Engine, MLX, dev on Mac, faster MVP    |
| On-device LLM    | MLX-Swift + Llama 3.2 3B Instruct Q4    | Best perf on Apple silicon; ~2 GB on disk            |
| Embeddings       | sentence-transformers all-MiniLM-L6-v2  | 384-dim, ~80 MB, well-supported, CPU-runnable        |
| Vector store     | sqlite-vec (vec0 virtual table)         | Single file, mobile-friendly, mature                 |
| Keyword search   | SQLite FTS5                             | Bundled in SQLite, fast, fuzzy via trigram tokenizer |
| Pack format      | ZIP w/ SHA-256 + (later) Ed25519 sig    | Universally supported, easy to distribute            |
| Pack builder     | Python 3.10+ (click, sentence-transformers, pyyaml) | Best ML tooling                          |
| Storage (iOS)    | SQLite via SQLite.swift                 | Mature, ergonomic, sqlite-vec compatible             |
| Distribution     | App Store + .trailpack via R2/S3        | Standard; signed manifests for integrity             |

**Explicitly rejected**:
- ❌ React Native — adds complexity, llama.rn is fiddly, MLX-Swift is better on iOS
- ❌ Training a custom model — RAG over curated content is the right approach
- ❌ Cloud LLM with offline fallback — defeats the whole product premise
- ❌ Full MCP runtime on device for v1 — adds surface area; revisit post-MVP for partner integrations

---

## Pack Format (.trailpack)

A `.trailpack` is a ZIP file with this structure:

```
camping-v1.trailpack/
├── manifest.yaml           # pack id, version, sizes, hashes, model_ref
├── pack.sqlite             # chunks + FTS5 index + procedures + sources
├── vectors.sqlite          # sqlite-vec embedding index
├── safety_rules.yaml       # intent → behavior rules
├── licenses.json           # source attribution
├── media/                  # diagrams (SVG preferred)
└── model/                  # OPTIONAL — .mlx or .gguf if pack-bundled
```

**Manifest schema** (excerpt):
```yaml
id: camping
version: 1.0.0
display_name: Camping Essentials
description: ...
size_bytes: 1234567
chunk_count: 847
created_at: 2026-05-16T00:00:00Z
app_min_version: 1.0.0
model:
  family: llama-3.2-3b-instruct
  quantization: q4
  ref: shared           # or "bundled" with path
embeddings:
  model: all-MiniLM-L6-v2
  dim: 384
hashes:
  pack.sqlite: sha256:...
  vectors.sqlite: sha256:...
  safety_rules.yaml: sha256:...
signature: ed25519:...   # post-MVP
```

**`pack.sqlite` schema**:
- `sources(id, title, publisher, url, license, retrieved_at, notes)`
- `chunks(id, source_id, domain, topic, subtopic, hazard_level, tags, chunk_text, created_at)`
- `procedures(id, title, domain, emergency_level, steps_json, warnings_json, source_id)`
- `chunks_fts(chunk_id, chunk_text, tags)` — FTS5 virtual table

**`safety_rules.yaml` schema**:
```yaml
- intent: first_aid
  match: [bleeding, burn, hypothermia, choking, cpr, snake bite, fracture]
  risk: high
  answer_mode: locked_procedure   # bypass LLM, render procedure card
  must_include:
    - "Seek emergency help (call 911 or activate PLB) if available."
  refuse_patterns:
    - dosage_questions
    - diagnosis_questions

- intent: plant_id
  match: [is this safe to eat, can I eat, edible, identify mushroom]
  risk: critical
  answer_mode: refuse_with_warning
  must_include:
    - "Never eat anything from the wild based on app guidance alone."

- intent: animal_encounter
  match: [bear, mountain lion, cougar, moose, snake]
  risk: medium
  answer_mode: rag_with_safety_appendix
  must_include:
    - "Behaviors differ by species and region."
```

---

## Safety Stance

| Domain          | Behavior                                                      |
|-----------------|---------------------------------------------------------------|
| First aid       | Locked procedure cards; LLM may explain wording, never invent |
| Edible plants   | Refuse "safe to eat" questions; surface identification info only |
| Edible animals  | Same as plants                                                |
| Wildlife encounter | RAG with safety appendix; region-aware where data exists  |
| Navigation      | Education only; no route-safety claims                        |
| Weather         | Cautious; defer to user judgment + cite source                |
| Knots           | Free explanation (low risk)                                   |
| Gear repair     | Free explanation                                              |

**Enforcement**: SafetyRouter classifies intent *before* the LLM ever sees the query. High-risk intents skip the LLM entirely and render a locked card. The LLM never generates new safety claims — only summarizes retrieved chunks.

---

## Content Authoring Principles

1. **One idea per chunk** (rough cap: 300 words / ~1500 chars)
2. **Frontmatter mandatory**: `source`, `license`, `domain`, `hazard_level`, `tags`, `last_reviewed`, `status` (draft / reviewed / sme_approved)
3. **Conservative voice**: always defer to professional help when relevant
4. **Cite freshness**: include "last reviewed" date — outdoor knowledge changes (bear behavior research, first aid protocols)
5. **No medical dosages** in v1
6. **No edibility assertions** in v1
7. **Source preference**: public domain (NPS, USFS, NOAA, USCG, CDC) > permissive-license texts > author-paraphrased with full attribution

---

## Critical Files / Paths

**Phase 0–1** (this session's deliverables):
- `docs/plan.md` — this plan, in-repo
- `docs/content-style-guide.md` — how to write a chunk
- `docs/safety-rules-spec.md` — schema reference
- `pack-builder/pyproject.toml` — Python project
- `pack-builder/src/pack_builder/cli.py` — entry point
- `pack-builder/src/pack_builder/{loader,chunker,embedder,packager,retriever,safety,schemas}.py`
- `packs/camping/manifest.yaml`
- `packs/camping/safety_rules.yaml`
- `packs/camping/content/**/*.md` — ~100 seed chunks
- `evals/camping-100q.yaml` — held-out test questions
- `.gitignore`

**Phase 2+** (later sessions):
- `app/Outdoor.xcodeproj/`
- `app/Outdoor/Core/Packs/PackManager.swift`
- `app/Outdoor/Core/Retrieval/Retriever.swift`
- `app/Outdoor/Core/LLM/MLXRunner.swift`
- `app/Outdoor/Core/Safety/SafetyRouter.swift`
- `app/Outdoor/Features/Chat/ChatView.swift`
- `app/Outdoor/Features/Emergency/EmergencyView.swift`

---

## Verification Plan

**Phase 1 (CLI demo)**:
- Run `pack-builder build packs/camping` — outputs `dist/camping-v1.trailpack` < 200 MB
- Run `pack-builder validate packs/camping` — all chunks pass schema
- Run `pack-builder query "how to purify water"` — returns 3–5 ranked chunks with sources
- Manually verify 20 sample queries across all 12 domains return relevant chunks
- Edge cases: out-of-pack query ("how do I fix a carburetor") returns "no relevant chunks"

**Phase 2 (iOS shell)**:
- Cold install on physical iPhone, enable airplane mode, type query → see chunks
- Pack catalog shows 1 installed pack and N "coming soon" entries
- Uninstall pack → chat shows "No pack installed"

**Phase 3 (LLM)**:
- 100-question eval — target 90%+ "useful" rating (manual grading)
- 50-question red-team eval — target 0 unsafe outputs
- Time to first token < 8s on iPhone 14
- Memory peak < 3 GB

**Phase 5 (Beta)**:
- 10–25 testers, 2-week field period
- NPS-style: "Would you bring this on a real trip?" → target 70%+ yes

---

## Risks + Mitigations

| Risk                              | Impact | Mitigation                                                          |
|-----------------------------------|--------|---------------------------------------------------------------------|
| Local model too slow on iPhone    | High   | Start with 3B Q4; benchmark early; fallback to 1B; consider Q3      |
| Hallucinated safety guidance      | Critical | RAG-only; safety router; refusal-by-default for high-risk          |
| Content licensing                 | High   | Public-domain sources first; track license per source row           |
| Pack size > 2 GB                  | Medium | Compress media; sqlite-vec efficient; separate model from content   |
| App Store rejection (medical claims) | Medium | Clear AI disclosure; "not medical advice" banners; no diagnosis    |
| Scope creep                       | Medium | Camping pack only; no maps/voice/camera in v1                       |
| MLX-Swift API changes             | Low    | Vendor a known-good version; pin                                    |

---

## Success Metrics (MVP shipped state)

- 90%+ of 100-question eval set returns useful cited answer offline
- 0 critical unsafe outputs in 50-question red-team
- Pack install reliability ≥ 95% across 25 beta installs
- Total package size (app + camping pack + model) ≤ 1.5 GB
- Time to first token ≤ 8s on iPhone 14
- 70%+ of beta testers would use on a real trip

---

## Out-of-Scope Reminders

- ❌ Android in v1 (Phase 6)
- ❌ Image-based plant ID in v1 (Phase 9, gated)
- ❌ Voice in v1
- ❌ Offline maps in v1 (Phase 8 add-on)
- ❌ Custom hardware ever (validate app demand first)
- ❌ Training a model
- ❌ Cloud LLM fallback
