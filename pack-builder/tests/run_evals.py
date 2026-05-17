"""Run the eval set against a built pack and report pass/fail per query.

Usage:
    HF_HUB_OFFLINE=1 python tests/run_evals.py \
        --pack ../dist/camping-v0.1.0.trailpack \
        --evals ../evals/camping-eval.yaml
"""

from __future__ import annotations

import argparse
import sys
import zipfile
from pathlib import Path

import yaml

from pack_builder.retriever import TrailpackReader
from pack_builder.safety import classify


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--pack", required=True, type=Path)
    ap.add_argument("--evals", required=True, type=Path)
    args = ap.parse_args()

    with args.evals.open() as f:
        evals = yaml.safe_load(f)

    # Load safety rules from the pack
    with zipfile.ZipFile(args.pack, "r") as zf:
        with zf.open("safety_rules.yaml") as f:
            rules = yaml.safe_load(f) or []

    pass_count = 0
    fail_count = 0
    total = len(evals)

    with TrailpackReader(args.pack) as reader:
        for i, e in enumerate(evals, 1):
            q = e["query"]
            decision = classify(q, rules)
            results = reader.query(q, k=3)

            # Three eval modes:
            # 1. expected_safety_intent + expected_answer_mode → check safety routing
            # 2. expected_domain → check that domain appears in top 3
            # 3. expected_keywords → at least one keyword in top result text

            failures: list[str] = []

            if "expected_safety_intent" in e:
                if decision.intent != e["expected_safety_intent"]:
                    failures.append(
                        f"intent: got {decision.intent!r}, expected {e['expected_safety_intent']!r}"
                    )
                if e.get("expected_answer_mode") and decision.answer_mode != e["expected_answer_mode"]:
                    failures.append(
                        f"mode: got {decision.answer_mode!r}, expected {e['expected_answer_mode']!r}"
                    )

            if "expected_domain" in e:
                # Skip retrieval check if safety refused (no chunks returned)
                if decision.answer_mode != "refuse_with_warning":
                    top3_domains = {c.domain for c in results[:3]}
                    if e["expected_domain"] not in top3_domains:
                        failures.append(
                            f"domain: expected {e['expected_domain']!r} in top 3, got {sorted(top3_domains)}"
                        )

            if "expected_keywords" in e and decision.answer_mode != "refuse_with_warning":
                top_text = results[0].text.lower() if results else ""
                keywords = [k.lower() for k in e["expected_keywords"]]
                if not any(kw in top_text for kw in keywords):
                    failures.append(
                        f"keywords: none of {keywords} in top result text"
                    )

            if failures:
                fail_count += 1
                print(f"✗ [{i}/{total}] {q!r}")
                for f in failures:
                    print(f"    - {f}")
            else:
                pass_count += 1
                if results:
                    top = results[0]
                    print(f"✓ [{i}/{total}] {q!r} → {top.section_title!r} ({top.domain})")
                else:
                    print(f"✓ [{i}/{total}] {q!r} → refused ({decision.intent})")

    print(f"\n{pass_count}/{total} passed, {fail_count} failed")
    return 0 if fail_count == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
