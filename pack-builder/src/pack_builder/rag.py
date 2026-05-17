"""End-to-end RAG pipeline for the CLI demo.

Implements the spec in `docs/prompt-spec.md` and `docs/retrieval-llm-contract.md`.

Pipeline:
  1. Open the .trailpack
  2. Classify the query via the SafetyRouter
  3. Based on answer_mode:
       - refuse_with_warning  → emit fixed refusal text, do not call LLM
       - locked_procedure     → emit retrieved chunks as a procedure card, do not call LLM
       - rag_with_safety_appendix → call LLM with safety appendix injected
       - rag_freeform         → call LLM normally
  4. Retrieve top-k chunks (filtered by score threshold)
  5. Build system + user prompts per prompt-spec.md
  6. Stream tokens via the chosen backend
  7. Post-process: validate citations, strip invented chunk_ids

LLM backends (strategy pattern, swap via --backend flag):
  - print      : prints the constructed prompt; no LLM. Useful for spec verification.
  - anthropic  : calls Anthropic API (dev convenience; requires ANTHROPIC_API_KEY).
  - mlx        : runs Llama 3.2 via mlx-lm (Apple Silicon only; requires model download).
  - llama-cpp  : runs a GGUF model via llama-cpp-python (cross-platform).

The Swift PromptBuilder must produce byte-identical output for the same inputs;
this module is the canonical reference implementation.
"""

from __future__ import annotations

import os
import re
from collections.abc import Iterator
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Protocol

import yaml

from .retriever import RetrievedChunk, TrailpackReader
from .safety import RouteDecision, classify

# ----------------------------------------------------------------------------
# Constants — keep in sync with docs/prompt-spec.md
# ----------------------------------------------------------------------------

PROMPT_DIR = Path(__file__).parent / "prompts"
SYSTEM_PROMPT_PATH = PROMPT_DIR / "system.txt"

# Score thresholds (see docs/prompt-spec.md § Score-based filtering)
STRONG_MATCH_THRESHOLD = 0.6
WEAK_MATCH_THRESHOLD = 0.4
DEFAULT_K = 5
CHUNK_TEXT_CAP_CHARS = 1500

# Sampling
DEFAULT_TEMPERATURE = 0.3
DEFAULT_TOP_P = 0.9
DEFAULT_MAX_TOKENS = 512

# Fixed refusal templates — must match docs/prompt-spec.md exactly
REFUSAL_NO_CONTEXT = (
    "The downloaded Camping pack does not cover this. "
    "Try downloading a more specific pack for this topic."
)
REFUSAL_LOW_CONFIDENCE = (
    "I'm not confident enough to answer this from your downloaded pack. "
    "Please check a regional field guide or a local expert."
)
REFUSAL_EDIBILITY = (
    "I will not assess whether any wild plant or animal is safe to eat. "
    "Always confirm edibility with a trained local expert or trusted field guide."
)
REFUSAL_DOSAGE = (
    "I will not give medication dosages. Use the dosing instructions on the medication's "
    "own packaging or call Poison Control (1-800-222-1222 in the U.S.)."
)
REFUSAL_DIAGNOSIS = (
    "I will not diagnose medical conditions. "
    "If you are concerned about an injury or illness, seek professional medical care."
)

LOW_CONFIDENCE_PREFIX = (
    "NOTE: low-confidence match — answer cautiously and recommend the user "
    "check a regional guide."
)

# Map safety intents to specific refusal templates
INTENT_REFUSAL_MAP: dict[str, str] = {
    "medication_dosage": REFUSAL_DOSAGE,
    "plant_id_edibility": REFUSAL_EDIBILITY,
    "animal_id_edibility": REFUSAL_EDIBILITY,
}


# ----------------------------------------------------------------------------
# Data shapes
# ----------------------------------------------------------------------------


@dataclass
class RAGAnswer:
    """Result of one RAG turn."""

    query: str
    answer: str                       # final answer text (post-validation)
    answer_mode: str                  # the SafetyRouter's decision
    intent: str
    risk: str
    citations_valid: list[str] = field(default_factory=list)
    citations_invalid_stripped: list[str] = field(default_factory=list)
    retrieved_chunks: list[RetrievedChunk] = field(default_factory=list)
    system_prompt: str = ""
    user_message: str = ""
    backend: str = ""


# ----------------------------------------------------------------------------
# Backend protocol
# ----------------------------------------------------------------------------


class LLMBackend(Protocol):
    """An LLM that streams text given a system prompt and a user message."""

    name: str

    def stream(
        self,
        system_prompt: str,
        user_message: str,
        temperature: float = DEFAULT_TEMPERATURE,
        max_tokens: int = DEFAULT_MAX_TOKENS,
    ) -> Iterator[str]:
        ...


class PrintBackend:
    """Prints the prompt that would be sent. No LLM. Useful for spec verification."""

    name = "print"

    def stream(
        self,
        system_prompt: str,
        user_message: str,
        temperature: float = DEFAULT_TEMPERATURE,
        max_tokens: int = DEFAULT_MAX_TOKENS,
    ) -> Iterator[str]:
        yield "═══ SYSTEM PROMPT ═══\n"
        yield system_prompt
        yield "\n\n═══ USER MESSAGE ═══\n"
        yield user_message
        yield "\n\n═══ (no LLM call — backend=print) ═══\n"


class AnthropicBackend:
    """Calls the Anthropic API. Dev convenience; requires ANTHROPIC_API_KEY env."""

    name = "anthropic"

    def __init__(self, model: str = "claude-3-5-sonnet-latest") -> None:
        try:
            from anthropic import Anthropic
        except ImportError as e:
            raise RuntimeError(
                "anthropic backend requires `pip install anthropic`"
            ) from e
        api_key = os.environ.get("ANTHROPIC_API_KEY")
        if not api_key:
            raise RuntimeError(
                "anthropic backend requires ANTHROPIC_API_KEY env var"
            )
        self._client = Anthropic(api_key=api_key)
        self._model = model

    def stream(
        self,
        system_prompt: str,
        user_message: str,
        temperature: float = DEFAULT_TEMPERATURE,
        max_tokens: int = DEFAULT_MAX_TOKENS,
    ) -> Iterator[str]:
        with self._client.messages.stream(
            model=self._model,
            max_tokens=max_tokens,
            temperature=temperature,
            system=system_prompt,
            messages=[{"role": "user", "content": user_message}],
        ) as stream:
            for chunk in stream.text_stream:
                yield chunk


class MLXBackend:
    """Runs a 4-bit quantized Llama via mlx-lm (Apple Silicon only)."""

    name = "mlx"

    def __init__(self, model_id: str = "mlx-community/Llama-3.2-3B-Instruct-4bit") -> None:
        try:
            from mlx_lm import load, stream_generate  # noqa: F401
        except ImportError as e:
            raise RuntimeError(
                "mlx backend requires `pip install mlx-lm` (Apple Silicon only)"
            ) from e
        from mlx_lm import load

        self._model, self._tokenizer = load(model_id)

    def stream(
        self,
        system_prompt: str,
        user_message: str,
        temperature: float = DEFAULT_TEMPERATURE,
        max_tokens: int = DEFAULT_MAX_TOKENS,
    ) -> Iterator[str]:
        from mlx_lm import stream_generate

        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_message},
        ]
        prompt = self._tokenizer.apply_chat_template(
            messages, tokenize=False, add_generation_prompt=True
        )
        for chunk in stream_generate(
            self._model,
            self._tokenizer,
            prompt=prompt,
            max_tokens=max_tokens,
            temp=temperature,
        ):
            yield chunk.text


class LlamaCppBackend:
    """Runs a GGUF model via llama-cpp-python."""

    name = "llama-cpp"

    def __init__(self, model_path: str, n_ctx: int = 8192) -> None:
        try:
            from llama_cpp import Llama
        except ImportError as e:
            raise RuntimeError(
                "llama-cpp backend requires `pip install llama-cpp-python`"
            ) from e
        self._llm = Llama(model_path=model_path, n_ctx=n_ctx, verbose=False)

    def stream(
        self,
        system_prompt: str,
        user_message: str,
        temperature: float = DEFAULT_TEMPERATURE,
        max_tokens: int = DEFAULT_MAX_TOKENS,
    ) -> Iterator[str]:
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_message},
        ]
        stream = self._llm.create_chat_completion(
            messages=messages,
            max_tokens=max_tokens,
            temperature=temperature,
            stream=True,
        )
        for chunk in stream:
            delta = chunk["choices"][0]["delta"].get("content")
            if delta:
                yield delta


def make_backend(name: str, **kwargs: Any) -> LLMBackend:
    name = name.lower()
    if name == "print":
        return PrintBackend()
    if name == "anthropic":
        return AnthropicBackend(**kwargs)
    if name == "mlx":
        return MLXBackend(**kwargs)
    if name in ("llama-cpp", "llamacpp", "gguf"):
        return LlamaCppBackend(**kwargs)
    raise ValueError(f"unknown backend: {name}")


# ----------------------------------------------------------------------------
# Prompt construction
# ----------------------------------------------------------------------------


def load_system_prompt(path: Path = SYSTEM_PROMPT_PATH) -> str:
    return path.read_text(encoding="utf-8").strip()


def format_context_block(chunks: list[RetrievedChunk]) -> str:
    """Render retrieved chunks as the context block defined in prompt-spec.md."""
    parts: list[str] = []
    for c in chunks:
        text = c.text
        if len(text) > CHUNK_TEXT_CAP_CHARS:
            text = text[: CHUNK_TEXT_CAP_CHARS - 1].rstrip() + "…"
        header = (
            f"[{c.chunk_id}] (domain: {c.domain}, hazard: {c.hazard_level}, "
            f"source: {c.source_title} — {c.source_publisher})"
        )
        title = c.section_title or ""
        block = f"{header}\n{title}\n\n{text}".rstrip()
        parts.append(block)
    return "\n\n---\n\n".join(parts)


def build_user_message(
    query: str,
    chunks: list[RetrievedChunk],
    decision: RouteDecision,
    low_confidence: bool = False,
) -> str:
    """Assemble the user message body per prompt-spec.md."""
    parts: list[str] = []

    if low_confidence:
        parts.append(LOW_CONFIDENCE_PREFIX)

    # Safety appendix from must_include lines on the matched rule
    if decision.answer_mode == "rag_with_safety_appendix" and decision.must_include:
        parts.append(
            "SAFETY REQUIREMENTS (include equivalent language in your answer):\n"
            + "\n".join(f"- {m}" for m in decision.must_include)
        )

    parts.append(f"QUESTION:\n{query}")
    parts.append(f"REFERENCE EXCERPTS:\n{format_context_block(chunks)}")
    return "\n\n".join(parts)


# ----------------------------------------------------------------------------
# Citation validation
# ----------------------------------------------------------------------------

_CITATION_RE = re.compile(r"\[([a-z0-9_\-]+\.[a-z0-9_\-]+(?:#[0-9.]+)?)\]")


def validate_citations(
    answer: str, retrieved: list[RetrievedChunk]
) -> tuple[str, list[str], list[str]]:
    """Strip invented citations from the answer. Returns (cleaned, valid_ids, stripped_ids)."""
    valid_ids = {c.chunk_id for c in retrieved}
    found = _CITATION_RE.findall(answer)
    invalid = sorted(set(found) - valid_ids)
    valid = sorted(set(found) & valid_ids)

    cleaned = answer
    for bad in invalid:
        # Strip "[bad_id]" and clean up resulting double spaces
        cleaned = cleaned.replace(f"[{bad}]", "")
    cleaned = re.sub(r"  +", " ", cleaned).replace(" ,", ",").replace(" .", ".")

    return cleaned.strip(), valid, invalid


# ----------------------------------------------------------------------------
# Main entry: answer()
# ----------------------------------------------------------------------------


def _filter_chunks_by_score(
    chunks: list[RetrievedChunk],
) -> tuple[list[RetrievedChunk], bool, bool]:
    """Apply the score thresholds. Returns (kept, all_weak, none_strong)."""
    kept = [c for c in chunks if c.score_hybrid >= WEAK_MATCH_THRESHOLD]
    if not kept:
        return [], False, True
    all_weak = all(c.score_hybrid < STRONG_MATCH_THRESHOLD for c in kept)
    none_strong = all_weak
    return kept, all_weak, none_strong


def _load_safety_rules(reader: TrailpackReader) -> list[dict[str, Any]]:
    safety_path = reader.root / "safety_rules.yaml"
    if not safety_path.exists():
        return []
    with safety_path.open() as f:
        return yaml.safe_load(f) or []


def answer(
    query: str,
    pack_path: Path,
    backend: LLMBackend | None = None,
    k: int = DEFAULT_K,
    temperature: float = DEFAULT_TEMPERATURE,
    max_tokens: int = DEFAULT_MAX_TOKENS,
    on_token: callable | None = None,
) -> RAGAnswer:
    """Run one full RAG turn against the pack and return the answer.

    `on_token` is an optional callback invoked with each streamed token chunk
    (for live CLI rendering). If None, tokens are accumulated silently.
    """
    backend = backend or PrintBackend()

    with TrailpackReader(pack_path) as reader:
        safety_rules = _load_safety_rules(reader)
        decision = classify(query, safety_rules)
        retrieved = reader.query(query, k=k)

    # Score-based filtering
    retrieved, all_weak, none_kept = _filter_chunks_by_score(retrieved)

    system_prompt = load_system_prompt()

    # ---- Refusal branches: do NOT call the LLM ----
    if decision.answer_mode == "refuse_with_warning":
        refusal = INTENT_REFUSAL_MAP.get(decision.intent)
        if not refusal and decision.must_include:
            refusal = "\n".join(decision.must_include)
        if not refusal:
            refusal = REFUSAL_NO_CONTEXT
        return RAGAnswer(
            query=query,
            answer=refusal,
            answer_mode=decision.answer_mode,
            intent=decision.intent,
            risk=decision.risk,
            retrieved_chunks=retrieved,
            backend=backend.name,
            system_prompt=system_prompt,
            user_message="(refused — LLM not called)",
        )

    if none_kept:
        return RAGAnswer(
            query=query,
            answer=REFUSAL_NO_CONTEXT,
            answer_mode="refuse_with_warning",
            intent="out_of_pack",
            risk="low",
            retrieved_chunks=[],
            backend=backend.name,
            system_prompt=system_prompt,
            user_message="(no retrieved chunks above threshold — LLM not called)",
        )

    if decision.answer_mode == "locked_procedure":
        # Render the procedure as a structured card without invoking the LLM.
        # The Swift app will render this as the EmergencyMode locked card.
        lines = []
        if decision.must_include:
            lines.append("⚠ " + "\n⚠ ".join(decision.must_include))
            lines.append("")
        for i, c in enumerate(retrieved, 1):
            lines.append(f"--- {i}. {c.section_title} (from {c.source_title}) ---")
            lines.append(c.text)
            lines.append(f"[{c.chunk_id}]")
            lines.append("")
        return RAGAnswer(
            query=query,
            answer="\n".join(lines).rstrip(),
            answer_mode=decision.answer_mode,
            intent=decision.intent,
            risk=decision.risk,
            retrieved_chunks=retrieved,
            citations_valid=[c.chunk_id for c in retrieved],
            backend=backend.name,
            system_prompt=system_prompt,
            user_message="(locked procedure — LLM not called)",
        )

    # ---- Normal RAG (rag_freeform or rag_with_safety_appendix) ----
    user_message = build_user_message(
        query=query,
        chunks=retrieved,
        decision=decision,
        low_confidence=all_weak,
    )

    pieces: list[str] = []
    for tok in backend.stream(
        system_prompt=system_prompt,
        user_message=user_message,
        temperature=temperature,
        max_tokens=max_tokens,
    ):
        pieces.append(tok)
        if on_token is not None:
            on_token(tok)

    raw_answer = "".join(pieces).strip()

    # Citation validation (skip for print backend — output is the prompt itself)
    if backend.name == "print":
        cleaned, valid, invalid = raw_answer, [], []
    else:
        cleaned, valid, invalid = validate_citations(raw_answer, retrieved)
        if not valid and decision.answer_mode != "refuse_with_warning":
            cleaned = (
                "⚠️ Answer is not grounded in the pack — verify with a trusted source.\n\n"
                + cleaned
            )

    return RAGAnswer(
        query=query,
        answer=cleaned,
        answer_mode=decision.answer_mode,
        intent=decision.intent,
        risk=decision.risk,
        citations_valid=valid,
        citations_invalid_stripped=invalid,
        retrieved_chunks=retrieved,
        backend=backend.name,
        system_prompt=system_prompt,
        user_message=user_message,
    )
