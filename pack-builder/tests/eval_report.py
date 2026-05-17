"""Run an eval set against a built pack and produce a markdown report.

For each query we capture: safety routing decision, top-3 retrieved chunks,
keyword match against expectations, and a pass/weak/fail verdict.

Usage:
    HF_HUB_OFFLINE=1 python tests/eval_report.py \
        --pack ../dist/camping-v0.1.0.trailpack \
        --evals ../evals/camping-100q.yaml \
        --out ../evals/report.md
"""

from __future__ import annotations

import argparse
import sys
import zipfile
from pathlib import Path
from typing import Any

import yaml

from pack_builder.retriever import TrailpackReader
from pack_builder.safety import classify


def grade(result: dict[str, Any], decision, chunks) -> tuple[str, list[str]]:
    """Return verdict + list of explanation lines."""
    notes: list[str] = []
    verdict = "pass"

    # Refusal expectations
    expected_intent = result.get("expected_safety_intent") or result.get("expected_intent")
    if expected_intent:
        if decision.intent != expected_intent:
            verdict = "FAIL"
            notes.append(f"intent: got {decision.intent!r}, expected {expected_intent!r}")
        elif decision.answer_mode != "refuse_with_warning":
            verdict = "WEAK"
            notes.append(f"answer_mode {decision.answer_mode!r} (refusal expected)")
        return verdict, notes

    # Domain check (top-3)
    expected_domain = result.get("expected_domain")
    top3_domains: list[str] = []
    if expected_domain:
        if decision.answer_mode == "refuse_with_warning":
            verdict = "FAIL"
            notes.append("unexpectedly refused")
            return verdict, notes
        top3_domains = [c.domain for c in chunks[:3]]
        if expected_domain not in top3_domains:
            verdict = "FAIL"
            notes.append(
                f"domain: top3 = {top3_domains}, expected {expected_domain!r}"
            )
        elif top3_domains[0] != expected_domain:
            verdict = "WEAK"
            notes.append(f"right domain but #{top3_domains.index(expected_domain) + 1}, not top")

    # Topic keywords check (against top result text)
    raw_topics = result.get("expected_topics") or result.get("expected_keywords") or []
    expected_topics = [str(t) for t in raw_topics]
    if expected_topics and chunks:
        top_text = chunks[0].text.lower()
        top_title = (chunks[0].section_title or "").lower()
        matched = [k for k in expected_topics if k.lower() in top_text or k.lower() in top_title]
        if not matched:
            if verdict == "pass":
                verdict = "WEAK"
            notes.append(f"no expected topic keywords found in top result: {expected_topics}")
        else:
            notes.append(f"top result hit keywords: {matched}")

    return verdict, notes


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--pack", required=True, type=Path)
    ap.add_argument("--evals", required=True, type=Path)
    ap.add_argument("--out", required=True, type=Path)
    args = ap.parse_args()

    with args.evals.open() as f:
        evals = yaml.safe_load(f)
    with zipfile.ZipFile(args.pack, "r") as zf:
        with zf.open("safety_rules.yaml") as f:
            rules = yaml.safe_load(f) or []

    rows: list[str] = []
    summary = {"pass": 0, "WEAK": 0, "FAIL": 0}
    by_domain: dict[str, dict[str, int]] = {}

    rows.append(f"# Eval Report — {args.pack.name}\n")
    rows.append(f"Eval set: `{args.evals.name}` · {len(evals)} queries\n")
    rows.append("Verdicts: ✓ pass · ◐ weak · ✗ fail\n")
    rows.append("")
    rows.append("---")
    rows.append("")

    with TrailpackReader(args.pack) as reader:
        for i, e in enumerate(evals, 1):
            q = e["query"]
            decision = classify(q, rules)
            chunks = []
            if decision.answer_mode != "refuse_with_warning":
                chunks = reader.query(q, k=3)
            verdict, notes = grade(e, decision, chunks)
            summary[verdict] = summary.get(verdict, 0) + 1
            dom_key = e.get("expected_domain") or "_other_"
            by_domain.setdefault(dom_key, {"pass": 0, "WEAK": 0, "FAIL": 0})
            by_domain[dom_key][verdict] = by_domain[dom_key].get(verdict, 0) + 1

            icon = {"pass": "✓", "WEAK": "◐", "FAIL": "✗"}[verdict]
            rows.append(f"## {icon} [{i}/{len(evals)}] {q!r}")
            rows.append("")
            if e.get("notes"):
                rows.append(f"> _{e['notes']}_")
                rows.append("")
            rows.append(
                f"**Safety:** intent=`{decision.intent}` · "
                f"mode=`{decision.answer_mode}` · risk=`{decision.risk}`"
            )
            rows.append("")
            for j, c in enumerate(chunks, 1):
                title = c.section_title or "(no title)"
                rows.append(
                    f"**{j}.** `{c.domain}` · *{title}* "
                    f"(hybrid={c.score_hybrid:.2f}, kw={c.score_keyword:.2f}, "
                    f"vec={c.score_vector:.2f}) — `{c.chunk_id}`"
                )
                # Show first 200 chars of the chunk text
                preview = c.text.replace("\n", " ").strip()
                if len(preview) > 240:
                    preview = preview[:237] + "…"
                rows.append(f"  > {preview}")
                rows.append("")
            for n in notes:
                rows.append(f"- _{n}_")
            rows.append("")
            rows.append("---")
            rows.append("")

    total = len(evals)
    rows.insert(4, "")
    rows.insert(4, f"## Summary")
    rows.insert(5, "")
    rows.insert(6, f"- ✓ pass: **{summary['pass']}** / {total} ({100*summary['pass']/total:.0f}%)")
    rows.insert(7, f"- ◐ weak: **{summary['WEAK']}** / {total}")
    rows.insert(8, f"- ✗ fail: **{summary['FAIL']}** / {total}")
    rows.insert(9, "")
    rows.insert(10, "### Per-domain")
    rows.insert(11, "")
    for dom in sorted(by_domain):
        v = by_domain[dom]
        tot = v["pass"] + v["WEAK"] + v["FAIL"]
        rows.insert(
            12,
            f"- `{dom}` — ✓ {v['pass']} · ◐ {v['WEAK']} · ✗ {v['FAIL']} / {tot}"
        )

    args.out.write_text("\n".join(rows), encoding="utf-8")
    print(
        f"Wrote {args.out} · pass {summary['pass']}/{total} · "
        f"weak {summary['WEAK']} · fail {summary['FAIL']}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
