"""Safety rule matcher used by the CLI demo (and reused as the Swift app's reference impl)."""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Any


@dataclass
class RouteDecision:
    intent: str
    answer_mode: str
    risk: str
    must_include: list[str]
    redirect: str | None
    matched_rule_index: int | None


def _build_pattern(keyword: str) -> re.Pattern[str]:
    # Treat each `match` entry as a case-insensitive substring search.
    return re.compile(re.escape(keyword), re.IGNORECASE)


def classify(query: str, rules: list[dict[str, Any]]) -> RouteDecision:
    """Run rules in order, first match wins. Falls back to `rag_freeform` if no match."""
    for i, rule in enumerate(rules):
        # Refuse-pattern check applies to high-risk content even before intent match
        for rp in rule.get("refuse_patterns", []) or []:
            if re.search(rp, query, re.IGNORECASE):
                return RouteDecision(
                    intent=rule["intent"],
                    answer_mode="refuse_with_warning",
                    risk=rule.get("risk", "high"),
                    must_include=rule.get("must_include", []) or [],
                    redirect=rule.get("redirect"),
                    matched_rule_index=i,
                )

        for kw in rule.get("match", []) or []:
            if _build_pattern(kw).search(query):
                return RouteDecision(
                    intent=rule["intent"],
                    answer_mode=rule["answer_mode"],
                    risk=rule.get("risk", "low"),
                    must_include=rule.get("must_include", []) or [],
                    redirect=rule.get("redirect"),
                    matched_rule_index=i,
                )

    return RouteDecision(
        intent="general",
        answer_mode="rag_freeform",
        risk="low",
        must_include=[],
        redirect=None,
        matched_rule_index=None,
    )
