# Prompt Spec — Outdoor v1

This document defines the exact prompt construction the PromptBuilder uses for the Camping pack. Both the Python prototype (`pack-builder/src/pack_builder/rag.py`) and the Swift PromptBuilder (`app/Outdoor/Core/LLM/PromptBuilder.swift`) must conform to this spec. Changes here are versioned alongside the model and pack format.

---

## Goals

1. **Ground every answer in retrieved chunks**. The LLM is a summarizer / explainer, never a knowledge source.
2. **Cite by chunk id**. Every claim references a specific chunk so the UI can surface citations.
3. **Refuse cleanly when the pack lacks the answer**. Better "I don't know" than a hallucination.
4. **Preserve safety language verbatim**. Conservative instructions in chunks (e.g. "seek emergency help if available") must pass through unmodified.
5. **Match the model's chat template**. Llama 3.2 Instruct expects a specific format; we build to it.

---

## Llama 3.2 chat template

Llama 3.2 Instruct expects messages in this shape:

```
<|begin_of_text|><|start_header_id|>system<|end_header_id|>

{system_prompt}<|eot_id|><|start_header_id|>user<|end_header_id|>

{user_message}<|eot_id|><|start_header_id|>assistant<|end_header_id|>

```

MLX-Swift's tokenizer applies this automatically when given a `[(role, content)]` array. The PromptBuilder produces the two strings; the runner formats them.

---

## System prompt (verbatim)

```
You are the Outdoor field guide assistant. You answer outdoor questions using ONLY the reference excerpts the user provides below. Follow these rules without exception:

1. Use only the provided excerpts. Do not draw on prior knowledge. If the excerpts do not cover the question, say "The downloaded Camping pack does not cover this. Try downloading a more specific pack for this topic." Do not guess.

2. Cite every factual claim by appending the chunk id in square brackets, e.g. [wildlife.bear-encounter#2]. Cite at the end of each sentence or paragraph that makes a claim. Do not invent chunk ids.

3. Preserve conservative safety language. If an excerpt contains phrases like "seek emergency help if available", "this is not medical advice", or "consult a professional", include equivalent caution in your answer.

4. Never give medication dosages, never assert that any wild plant or animal is safe to eat, never give specific weight or strength assessments for ropes, anchors, or gear, and never offer route-safety claims.

5. For first-aid questions, structure the answer as numbered steps when the excerpts contain a procedure. Lead with the most safety-critical step first.

6. If the user is in an emergency right now (their message indicates active injury, attack, being lost, severe weather), lead with the single most important action, then provide the rest. Keep it short and direct.

7. Be concise. Aim for 4-8 sentences unless the user asks for more detail. Hikers in the field need fast answers, not essays.
```

This system prompt is loaded from `app/Outdoor/Core/LLM/SystemPrompt.txt` (Swift) and the Python equivalent `pack-builder/src/pack_builder/prompts/system.txt`. Same file content in both places. Changes require a version bump.

---

## User message format

```
QUESTION:
{user_query}

REFERENCE EXCERPTS:
{context_block}
```

Where `{context_block}` is the formatted retrieved chunks (see next section).

---

## Context block format

Each `RetrievedChunk` is rendered as:

```
[{chunk_id}] (domain: {domain}, hazard: {hazard_level}, source: {source_title} — {source_publisher})
{section_title}

{text}

---
```

Chunks are emitted in `scoreHybrid` order (best first). Separator between chunks is `\n---\n`.

### Example

```
[wildlife.bear-encounter#2] (domain: wildlife, hazard: high, source: Staying Safe Around Bears — U.S. National Park Service)
If you see a bear at a distance

Stop and stay calm. Most bears will avoid you if they hear you coming. Maintain distance...

---

[wildlife.black-vs-grizzly-id#1] (domain: wildlife, hazard: high, source: Bear Identification — NPS Bear Safety Resources — U.S. National Park Service)
Shoulders

Grizzlies have a prominent muscular hump above the shoulders. Black bears do not...

---
```

---

## Score-based filtering (PromptBuilder responsibility)

Before formatting the context block:

1. Drop chunks with `scoreHybrid < 0.4`.
2. If 0 chunks remain → return the refusal message directly, **do not call the LLM**.
3. If only weak chunks remain (all `scoreHybrid < 0.6`), prepend a note to the user message: `"NOTE: low-confidence match — answer cautiously and recommend the user check a regional guide."`
4. Cap context at `k = 5` chunks (configurable per-pack later).
5. Cap each chunk's text at 1500 characters; truncate with `…` if longer. Token budget for context ~= 3500 tokens.

---

## Citation enforcement

The LLM is asked to cite, but we don't trust it to behave. Post-processing in the PromptBuilder:

1. Extract every `[chunk_id]` token from the model's output.
2. Verify each cited id appears in the retrieved set. **Strip any invented citations.**
3. If the answer has zero valid citations and was not the refusal message, prepend a warning: `"⚠️ Answer is not grounded in the pack — verify with a trusted source."`
4. Render citation chips in the UI tied to the chunk metadata so the user can tap to see the source.

---

## Refusal templates (exact strings)

These are short, fixed strings. The LLM is bypassed entirely when one of these applies — the PromptBuilder writes them directly.

```
REFUSAL_NO_CONTEXT       = "The downloaded Camping pack does not cover this. Try downloading a more specific pack for this topic."
REFUSAL_LOW_CONFIDENCE   = "I'm not confident enough to answer this from your downloaded pack. Please check a regional field guide or a local expert."
REFUSAL_EDIBILITY        = "I will not assess whether any wild plant or animal is safe to eat. Always confirm edibility with a trained local expert or trusted field guide."
REFUSAL_DOSAGE           = "I will not give medication dosages. Use the dosing instructions on the medication's own packaging or call Poison Control (1-800-222-1222 in the U.S.)."
REFUSAL_DIAGNOSIS        = "I will not diagnose medical conditions. If you are concerned about an injury or illness, seek professional medical care."
```

---

## Streaming behavior

The runner streams tokens. The PromptBuilder is responsible for:

1. Emitting a "thinking" indicator immediately on submit.
2. Streaming raw tokens to the UI as they arrive.
3. Running citation validation **after** the full response completes (we cannot strip mid-stream without breaking the cursor).
4. If validation removes citations or adds the ⚠️ warning, update the rendered message in-place.

---

## Sampling parameters

For the camping pack v1, use conservative sampling:

- `temperature = 0.3`
- `top_p = 0.9`
- `repetition_penalty = 1.1`
- `max_tokens = 512` (we want concise answers; field users don't read essays)

Lower temperature reduces hallucination, which matters more than creativity for a safety reference.

---

## Token budget

Llama 3.2 has a 128K context window, but on iPhone Q4 we should be conservative for memory.

Budget per request:
- System prompt: ~300 tokens
- User question: ~50 tokens
- Context block (5 chunks × 700 tokens): ~3500 tokens
- Response: ~512 tokens
- **Total: ~4400 tokens** — well within safe iPhone memory limits

If memory becomes tight on older devices, the first lever is reducing `k` from 5 to 3.

---

## Reference implementation

The Python prototype in `pack-builder/src/pack_builder/rag.py` is the canonical, runnable implementation of this spec. The Swift port must produce byte-identical output for the same retrieved chunks and query (modulo line endings).

A regression test is in `evals/prompt-golden.yaml` — 50 (query, retrieved_chunks_fixture, expected_prompt) tuples. Both implementations must pass it.
