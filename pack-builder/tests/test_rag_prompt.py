"""Unit tests for the RAG prompt builder.

These tests validate the deterministic prompt-construction code paths without
needing a built .trailpack or an actual LLM/embedder. They establish the
canonical reference behavior the Swift PromptBuilder must mirror.
"""

from __future__ import annotations

import pytest

from pack_builder.rag import (
    CHUNK_TEXT_CAP_CHARS,
    INTENT_REFUSAL_MAP,
    LOW_CONFIDENCE_PREFIX,
    REFUSAL_DOSAGE,
    REFUSAL_EDIBILITY,
    REFUSAL_NO_CONTEXT,
    build_user_message,
    format_context_block,
    load_system_prompt,
    validate_citations,
)
from pack_builder.retriever import RetrievedChunk
from pack_builder.safety import RouteDecision


def _chunk(
    chunk_id: str = "wildlife.bear-encounter#1",
    text: str = "Stop and stay calm. Maintain distance.",
    section_title: str = "If you see a bear",
    domain: str = "wildlife",
    hazard: str = "high",
    score_hybrid: float = 0.85,
    score_keyword: float = 0.6,
    score_vector: float = 0.95,
) -> RetrievedChunk:
    return RetrievedChunk(
        chunk_id=chunk_id,
        section_title=section_title,
        text=text,
        domain=domain,
        hazard_level=hazard,
        tags=["wildlife", "bear"],
        source_title="Staying Safe Around Bears",
        source_publisher="U.S. National Park Service",
        source_url="https://www.nps.gov/subjects/bears/safety.htm",
        score_keyword=score_keyword,
        score_vector=score_vector,
        score_hybrid=score_hybrid,
    )


def _decision(
    intent: str = "general",
    answer_mode: str = "rag_freeform",
    risk: str = "low",
    must_include: list[str] | None = None,
) -> RouteDecision:
    return RouteDecision(
        intent=intent,
        answer_mode=answer_mode,
        risk=risk,
        must_include=must_include or [],
        redirect=None,
        matched_rule_index=None,
    )


# ---------------------------------------------------------------------------
# load_system_prompt
# ---------------------------------------------------------------------------


def test_system_prompt_loads():
    sp = load_system_prompt()
    assert "Outdoor field guide assistant" in sp
    assert "ONLY the reference excerpts" in sp
    assert "do not draw on prior knowledge" in sp.lower()


# ---------------------------------------------------------------------------
# format_context_block
# ---------------------------------------------------------------------------


def test_format_context_block_single_chunk():
    out = format_context_block([_chunk()])
    assert "[wildlife.bear-encounter#1]" in out
    assert "domain: wildlife" in out
    assert "hazard: high" in out
    assert "Staying Safe Around Bears" in out
    assert "U.S. National Park Service" in out
    assert "If you see a bear" in out
    assert "Stop and stay calm." in out


def test_format_context_block_multiple_chunks_separated_by_rule():
    c1 = _chunk(chunk_id="a.b#1", text="First chunk.")
    c2 = _chunk(chunk_id="a.b#2", text="Second chunk.")
    out = format_context_block([c1, c2])
    assert "\n---\n" in out
    # Both chunks present
    assert "[a.b#1]" in out
    assert "[a.b#2]" in out


def test_format_context_block_truncates_long_text():
    long = "x" * (CHUNK_TEXT_CAP_CHARS + 500)
    out = format_context_block([_chunk(text=long)])
    # Body should be truncated and end with the ellipsis marker
    assert "…" in out
    # Total chunk body should be cap or less (plus the ellipsis char)
    body_marker = "Stop and stay calm" if False else "x"
    # quick sanity: body cap honored (allow a few chars margin for the header line)
    body_section = out.split("\n\n", 2)[-1]
    assert len(body_section) <= CHUNK_TEXT_CAP_CHARS + 50


def test_format_context_block_empty():
    assert format_context_block([]) == ""


# ---------------------------------------------------------------------------
# build_user_message
# ---------------------------------------------------------------------------


def test_user_message_includes_question_and_excerpts():
    msg = build_user_message(
        query="what to do if I see a bear",
        chunks=[_chunk()],
        decision=_decision(),
    )
    assert msg.startswith("QUESTION:\nwhat to do if I see a bear")
    assert "REFERENCE EXCERPTS:" in msg
    assert "[wildlife.bear-encounter#1]" in msg


def test_user_message_low_confidence_prefix():
    msg = build_user_message(
        query="something obscure",
        chunks=[_chunk(score_hybrid=0.42)],
        decision=_decision(),
        low_confidence=True,
    )
    assert msg.startswith(LOW_CONFIDENCE_PREFIX)


def test_user_message_safety_appendix_for_rag_with_safety_appendix():
    decision = _decision(
        intent="animal_encounter",
        answer_mode="rag_with_safety_appendix",
        risk="medium",
        must_include=["Behaviors differ by species and region."],
    )
    msg = build_user_message(
        query="grizzly bear sighting",
        chunks=[_chunk()],
        decision=decision,
    )
    assert "SAFETY REQUIREMENTS" in msg
    assert "Behaviors differ by species and region." in msg


def test_user_message_no_safety_appendix_for_freeform():
    decision = _decision(answer_mode="rag_freeform", must_include=["this should not appear"])
    msg = build_user_message(
        query="any question",
        chunks=[_chunk()],
        decision=decision,
    )
    assert "SAFETY REQUIREMENTS" not in msg


# ---------------------------------------------------------------------------
# validate_citations
# ---------------------------------------------------------------------------


def test_validate_citations_all_valid():
    chunks = [_chunk(chunk_id="a.b#1"), _chunk(chunk_id="c.d#2")]
    answer = "Stop [a.b#1]. Then back away [c.d#2]."
    cleaned, valid, invalid = validate_citations(answer, chunks)
    assert cleaned == answer
    assert sorted(valid) == ["a.b#1", "c.d#2"]
    assert invalid == []


def test_validate_citations_strips_invented():
    chunks = [_chunk(chunk_id="a.b#1")]
    answer = "Real cite [a.b#1]. Made up [made-up.fake#9]. Real again [a.b#1]."
    cleaned, valid, invalid = validate_citations(answer, chunks)
    assert "[made-up.fake#9]" not in cleaned
    assert "[a.b#1]" in cleaned
    assert valid == ["a.b#1"]
    assert invalid == ["made-up.fake#9"]


def test_validate_citations_handles_no_citations():
    chunks = [_chunk()]
    cleaned, valid, invalid = validate_citations("No citations here.", chunks)
    assert cleaned == "No citations here."
    assert valid == []
    assert invalid == []


def test_validate_citations_dedupes():
    chunks = [_chunk(chunk_id="a.b#1")]
    answer = "[a.b#1] something [a.b#1] more [a.b#1]."
    _, valid, invalid = validate_citations(answer, chunks)
    assert valid == ["a.b#1"]
    assert invalid == []


def test_validate_citations_recognizes_subsection_ids():
    """chunk_id may include #N or #N.M (chunker splits long sections)."""
    chunks = [_chunk(chunk_id="x.y#2.1")]
    _, valid, invalid = validate_citations("From the pack [x.y#2.1].", chunks)
    assert valid == ["x.y#2.1"]
    assert invalid == []


# ---------------------------------------------------------------------------
# Refusal templates are stable strings
# ---------------------------------------------------------------------------


def test_refusal_strings_exist_and_are_distinct():
    assert REFUSAL_NO_CONTEXT
    assert REFUSAL_EDIBILITY
    assert REFUSAL_DOSAGE
    assert REFUSAL_NO_CONTEXT != REFUSAL_EDIBILITY
    assert REFUSAL_EDIBILITY != REFUSAL_DOSAGE


def test_intent_refusal_map_covers_critical_intents():
    """Every critical-risk intent in the camping safety_rules should have a mapped refusal."""
    assert INTENT_REFUSAL_MAP["medication_dosage"] == REFUSAL_DOSAGE
    assert INTENT_REFUSAL_MAP["plant_id_edibility"] == REFUSAL_EDIBILITY
    assert INTENT_REFUSAL_MAP["animal_id_edibility"] == REFUSAL_EDIBILITY


# ---------------------------------------------------------------------------
# End-to-end (with PrintBackend) — no LLM, no embedder, no trailpack needed
# ---------------------------------------------------------------------------


def test_print_backend_streams_constructed_prompt():
    from pack_builder.rag import PrintBackend

    be = PrintBackend()
    out = "".join(be.stream("SYSTEM TEXT", "USER TEXT"))
    assert "SYSTEM TEXT" in out
    assert "USER TEXT" in out
    assert "no LLM call" in out
