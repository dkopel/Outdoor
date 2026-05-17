"""Validation for frontmatter, manifest, and safety rules.

We use lightweight hand-rolled validation rather than pydantic to keep deps small.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import date
from typing import Any

VALID_HAZARD_LEVELS = {"low", "medium", "high", "critical"}
VALID_STATUSES = {"draft", "reviewed", "sme_approved"}
VALID_LICENSES = {"public-domain", "cc-by", "cc-by-sa", "quoted-fair-use", "author"}
VALID_ANSWER_MODES = {
    "rag_freeform",
    "rag_with_safety_appendix",
    "locked_procedure",
    "refuse_with_warning",
    "redirect_pack",
}
VALID_RISKS = {"low", "medium", "high", "critical"}

REQUIRED_FRONTMATTER_FIELDS = (
    "id",
    "domain",
    "topic",
    "hazard_level",
    "tags",
    "source",
    "status",
    "last_reviewed",
)
REQUIRED_SOURCE_FIELDS = ("title", "publisher", "license")


@dataclass
class ValidationError:
    path: str
    message: str

    def __str__(self) -> str:
        return f"{self.path}: {self.message}"


@dataclass
class ValidationResult:
    errors: list[ValidationError] = field(default_factory=list)
    warnings: list[ValidationError] = field(default_factory=list)

    @property
    def ok(self) -> bool:
        return not self.errors

    def error(self, path: str, message: str) -> None:
        self.errors.append(ValidationError(path, message))

    def warn(self, path: str, message: str) -> None:
        self.warnings.append(ValidationError(path, message))


def validate_frontmatter(file_path: str, fm: dict[str, Any], result: ValidationResult) -> None:
    """Validate a single content file's frontmatter."""
    for field_name in REQUIRED_FRONTMATTER_FIELDS:
        if field_name not in fm:
            result.error(file_path, f"missing required frontmatter field: {field_name}")

    if "hazard_level" in fm and fm["hazard_level"] not in VALID_HAZARD_LEVELS:
        result.error(
            file_path,
            f"hazard_level '{fm['hazard_level']}' not in {sorted(VALID_HAZARD_LEVELS)}",
        )

    if "status" in fm and fm["status"] not in VALID_STATUSES:
        result.error(
            file_path, f"status '{fm['status']}' not in {sorted(VALID_STATUSES)}"
        )

    if "tags" in fm and not isinstance(fm["tags"], list):
        result.error(file_path, "tags must be a list")

    if "source" in fm:
        src = fm["source"]
        if not isinstance(src, dict):
            result.error(file_path, "source must be a mapping")
        else:
            for sf in REQUIRED_SOURCE_FIELDS:
                if sf not in src:
                    result.error(file_path, f"source missing field: {sf}")
            if "license" in src and src["license"] not in VALID_LICENSES:
                result.error(
                    file_path,
                    f"source.license '{src['license']}' not in {sorted(VALID_LICENSES)}",
                )

    if "last_reviewed" in fm:
        val = fm["last_reviewed"]
        if not isinstance(val, (date, str)):
            result.error(file_path, "last_reviewed must be an ISO date")


def validate_manifest(manifest: dict[str, Any], result: ValidationResult) -> None:
    """Validate a pack manifest.yaml."""
    required = ("id", "version", "display_name", "description")
    for f in required:
        if f not in manifest:
            result.error("manifest.yaml", f"missing required field: {f}")

    if "embeddings" in manifest:
        emb = manifest["embeddings"]
        if not isinstance(emb, dict) or "model" not in emb or "dim" not in emb:
            result.error("manifest.yaml", "embeddings must have 'model' and 'dim'")


def validate_safety_rules(rules: list[dict[str, Any]], result: ValidationResult) -> None:
    """Validate safety_rules.yaml (a list of rule dicts)."""
    if not isinstance(rules, list):
        result.error("safety_rules.yaml", "must be a list of rules")
        return

    seen_intents: set[str] = set()
    for i, rule in enumerate(rules):
        path = f"safety_rules.yaml[{i}]"
        if "intent" not in rule:
            result.error(path, "missing 'intent'")
            continue
        intent = rule["intent"]
        if intent in seen_intents:
            result.error(path, f"duplicate intent '{intent}'")
        seen_intents.add(intent)

        if "answer_mode" not in rule:
            result.error(path, "missing 'answer_mode'")
        elif rule["answer_mode"] not in VALID_ANSWER_MODES:
            result.error(
                path,
                f"answer_mode '{rule['answer_mode']}' not in {sorted(VALID_ANSWER_MODES)}",
            )

        if "risk" in rule and rule["risk"] not in VALID_RISKS:
            result.error(path, f"risk '{rule['risk']}' not in {sorted(VALID_RISKS)}")

        if "match" in rule and not isinstance(rule["match"], list):
            result.error(path, "'match' must be a list")
