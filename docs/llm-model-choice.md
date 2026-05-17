# On-Device LLM — Model Selection

**Status**: pre-benchmark. Decisions here are based on published specs and community benchmarks. The benchmark script `pack-builder/scripts/bench_models.py` (not yet written) will produce empirical numbers on the dev Mac and on an iPhone 14+ in a later step.

## Decision criteria (in priority order)

1. **Runs on iPhone 14 or later** — fits in unified memory headroom (≤3 GB peak, ideally under 2 GB)
2. **Time to first token ≤ 8 s** on iPhone 14 from a cold start
3. **Generation speed ≥ 8 tokens/sec** sustained
4. **Answer quality good enough** on the camping pack (passes 90% of the prompt-golden eval)
5. **Apache 2.0 / Llama license** that allows commercial use in a paid-pack model
6. **Active MLX-Swift support** (community maintains a current 4-bit MLX export on HuggingFace)

---

## Candidates

### Llama 3.2 3B Instruct, 4-bit MLX  *(primary candidate)*
- **HuggingFace**: `mlx-community/Llama-3.2-3B-Instruct-4bit`
- **Disk size**: ~1.8 GB
- **Quality**: strong instruction following, good RAG behavior, good citation discipline in informal benchmarks
- **iPhone fit**: 3 GB total RAM use estimated on iPhone 14; tight but feasible
- **License**: Llama Community License — commercial use allowed under the standard 700M-MAU clause we will not approach
- **Why first choice**: best quality-per-byte for our size budget; widely used in production RAG apps

### Llama 3.2 1B Instruct, 4-bit MLX  *(fallback if 3B is too slow)*
- **HuggingFace**: `mlx-community/Llama-3.2-1B-Instruct-4bit`
- **Disk size**: ~700 MB
- **Quality**: noticeably weaker than 3B; struggles with multi-step reasoning. Acceptable for summarizing pre-retrieved chunks (our use case).
- **iPhone fit**: comfortable on iPhone 12+
- **License**: Llama Community License
- **When**: if the 3B benchmarks show TTFT > 12 s on iPhone 14, or memory peaks above 3.5 GB

### Gemma 2 2B Instruct, 4-bit MLX  *(license alternative)*
- **HuggingFace**: `mlx-community/gemma-2-2b-it-4bit`
- **Disk size**: ~1.3 GB
- **Quality**: very competitive with Llama 3.2 3B on instruction-following benchmarks
- **iPhone fit**: similar to 3B Llama
- **License**: Gemma Terms of Use — restricts certain use cases; review before commit
- **When**: kept as backup in case Llama licensing becomes inconvenient

### Phi-3.5 Mini, 4-bit MLX  *(stretch)*
- **HuggingFace**: `mlx-community/Phi-3.5-mini-instruct-4bit`
- **Disk size**: ~2.2 GB
- **Quality**: strong reasoning for the size
- **iPhone fit**: at the edge; may not fit comfortably on iPhone 14 base RAM
- **License**: MIT (cleanest)
- **When**: if Llama 3.2 3B fails the quality bar but the device can take a slightly bigger model

### Models explicitly rejected
- **Llama 3.2 70B and larger**: cannot fit on any phone
- **Mistral 7B**: too large for current iPhone RAM budget at usable quantization
- **TinyLlama / SmolLM2 ≤1B**: quality insufficient for cited RAG answers in our internal smoke tests
- **GPTQ / AWQ formats**: less mature MLX-Swift support than mlx-community's bundled GGUF/MLX

---

## Benchmark plan (`pack-builder/scripts/bench_models.py`)

For each candidate (3B Llama, 1B Llama, 2B Gemma) on the dev Mac:

1. **Cold load time** — first model load from disk, no cache
2. **Warm load time** — second load with disk cache
3. **Time to first token (TTFT)** — system prompt + a 3-chunk RAG context (~1500 tokens) + a 30-word query → measure time until the first generated token
4. **Sustained throughput** — tokens/sec averaged over a 200-token completion
5. **Peak memory** — `resource.getrusage(resource.RUSAGE_SELF).ru_maxrss` immediately after generation
6. **Quality** — run the **prompt-golden** eval set (50 questions in `evals/prompt-golden.yaml`) and grade with the existing pass/fail rules

Each metric reported as a small Markdown table; full traces piped into `bench-output/`.

After Mac numbers, run the same TTFT and throughput on a real iPhone 14 via the `llm-prototype` Swift Package (Phase 3 sandbox work).

---

## Decision matrix (to be filled in after the benchmark run)

| Candidate | Disk | Mac TTFT | Mac t/s | iPhone TTFT | iPhone t/s | Quality (golden pass) | Pick? |
|-----------|------|----------|---------|-------------|------------|------------------------|-------|
| Llama 3.2 3B Q4 | ~1.8 GB | TBD | TBD | TBD | TBD | TBD | ? |
| Llama 3.2 1B Q4 | ~700 MB | TBD | TBD | TBD | TBD | TBD | ? |
| Gemma 2 2B Q4 | ~1.3 GB | TBD | TBD | TBD | TBD | TBD | ? |

**Rule**: pick the smallest model that passes the quality bar AND meets the iPhone latency bar.

---

## Distribution mechanics (post-decision)

Once the model is chosen:

1. **Pack-bundled** is the default: the `.trailpack` includes the model file in `model/` and the manifest's `model.ref` field is set to `"bundled"`.
2. **Shared model**: if multiple packs use the same model, the manifest's `model.ref: "shared"` causes the PackInstaller to dedupe via a content-hash-keyed model directory at `~/Library/Application Support/Outdoor/Models/<sha256-prefix>/`. Saves storage on phones with multiple packs.
3. **App Store size**: shipping a ~2 GB model inside the app binary is risky for App Store review and over-the-air downloads. Plan: app binary includes a tiny stub model for first-launch verification; the real model downloads as part of the camping pack on first pack install. Show a clear progress UI.

---

## Open questions to resolve during the benchmark step

1. **MLX-Swift vs llama.cpp on iOS** — MLX is faster on Apple silicon, but llama.cpp has wider model support. Benchmark both runtimes against the same Q4 weights; pick the runner that gives the better TTFT.
2. **Memory pressure on iPhone 13** — out of scope for v1 (we target iPhone 14+), but useful data for future iPhone 13 support.
3. **Battery drain per chat session** — measure as part of the iPhone benchmark; target < 2% battery per 10-message session.
4. **Background unload** — when ChatScreen is backgrounded > 5 min, unload model to free RAM (Phase 5 polish). Confirm reload time is acceptable.

---

## What's done in this session, what comes next

**Done now**:
- This decision doc, candidate list, and benchmark plan ✓
- Python RAG prototype works against any backend (`pack-builder rag --backend ...`) ✓
- Prompt spec and golden eval ready for the benchmark to grade against ✓

**Next session (when network and time allow)**:
- Write `pack-builder/scripts/bench_models.py`
- Download the three candidate models (~3.8 GB total)
- Run the benchmark, fill in the table above
- Commit decision, move into the `llm-prototype` Swift Package work
