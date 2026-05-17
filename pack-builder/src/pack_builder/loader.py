"""Load pack source dirs into in-memory dataclasses."""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import frontmatter
import yaml


@dataclass
class ContentFile:
    """A single authored Markdown file before chunking."""

    path: Path
    relative_path: str
    frontmatter: dict[str, Any]
    body: str


@dataclass
class PackSource:
    """A pack source directory loaded into memory."""

    root: Path
    manifest: dict[str, Any]
    safety_rules: list[dict[str, Any]]
    content_files: list[ContentFile] = field(default_factory=list)


def load_yaml(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def load_pack_source(pack_dir: Path) -> PackSource:
    """Load manifest, safety rules, and all content files from a pack source dir."""
    pack_dir = pack_dir.resolve()

    manifest_path = pack_dir / "manifest.yaml"
    if not manifest_path.exists():
        raise FileNotFoundError(f"missing {manifest_path}")
    manifest = load_yaml(manifest_path) or {}

    safety_path = pack_dir / "safety_rules.yaml"
    safety_rules: list[dict[str, Any]] = []
    if safety_path.exists():
        loaded = load_yaml(safety_path)
        if loaded is not None:
            safety_rules = loaded

    content_dir = pack_dir / "content"
    if not content_dir.exists():
        raise FileNotFoundError(f"missing {content_dir}")

    content_files: list[ContentFile] = []
    for md_path in sorted(content_dir.rglob("*.md")):
        with md_path.open("r", encoding="utf-8") as f:
            post = frontmatter.load(f)
        content_files.append(
            ContentFile(
                path=md_path,
                relative_path=str(md_path.relative_to(pack_dir)),
                frontmatter=dict(post.metadata),
                body=post.content,
            )
        )

    return PackSource(
        root=pack_dir,
        manifest=manifest,
        safety_rules=safety_rules,
        content_files=content_files,
    )
