"""Split content files into retrievable chunks.

Strategy: one chunk per `##` H2 section. If a file has no `##` headings,
the whole body becomes a single chunk. If a section is unusually long
(> CHAR_CAP), it is further split at paragraph boundaries.
"""

from __future__ import annotations

import hashlib
import re
from dataclasses import dataclass
from typing import Any

from .loader import ContentFile

CHAR_CAP = 1800  # rough upper bound; retrievers prefer focused chunks


@dataclass
class Chunk:
    chunk_id: str
    file_id: str
    section_index: int
    section_title: str
    text: str
    domain: str
    topic: str
    subtopic: str | None
    hazard_level: str
    tags: list[str]
    source_key: str  # synthetic key into the sources table


_H2_RE = re.compile(r"^##\s+(.+)$", re.MULTILINE)


def _split_by_h2(body: str) -> list[tuple[str, str]]:
    """Return list of (section_title, section_text). H1 (`# `) is treated as preamble titled '_intro'."""
    sections: list[tuple[str, str]] = []
    matches = list(_H2_RE.finditer(body))

    if not matches:
        # No H2s — treat the whole body (minus any H1) as one section
        cleaned = re.sub(r"^#\s+.*\n", "", body, count=1, flags=re.MULTILINE)
        cleaned = cleaned.strip()
        if cleaned:
            sections.append(("Overview", cleaned))
        return sections

    # Preamble before the first H2
    first_start = matches[0].start()
    preamble = body[:first_start]
    preamble = re.sub(r"^#\s+.*\n", "", preamble, count=1, flags=re.MULTILINE).strip()
    if preamble:
        sections.append(("Overview", preamble))

    for i, m in enumerate(matches):
        title = m.group(1).strip()
        start = m.end()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(body)
        text = body[start:end].strip()
        if text:
            sections.append((title, text))

    return sections


def _further_split(text: str) -> list[str]:
    """If a section is too long, split at paragraph boundaries."""
    if len(text) <= CHAR_CAP:
        return [text]

    paragraphs = re.split(r"\n\s*\n", text)
    out: list[str] = []
    buf = ""
    for p in paragraphs:
        if not buf:
            buf = p
        elif len(buf) + len(p) + 2 <= CHAR_CAP:
            buf = f"{buf}\n\n{p}"
        else:
            out.append(buf)
            buf = p
    if buf:
        out.append(buf)
    return out


def _chunk_id(file_id: str, section_index: int, sub_index: int | None = None) -> str:
    base = f"{file_id}#{section_index}"
    if sub_index is not None:
        base = f"{base}.{sub_index}"
    return base


def _source_key(source: dict[str, Any]) -> str:
    """Stable key for a source object, used to dedupe rows in the sources table."""
    title = source.get("title", "")
    publisher = source.get("publisher", "")
    url = source.get("url", "")
    raw = f"{title}|{publisher}|{url}".encode("utf-8")
    return hashlib.sha1(raw).hexdigest()[:16]


def chunk_file(cf: ContentFile) -> list[Chunk]:
    fm = cf.frontmatter
    file_id = fm.get("id") or cf.relative_path
    domain = fm.get("domain", "")
    topic = fm.get("topic", "")
    subtopic = fm.get("subtopic")
    hazard_level = fm.get("hazard_level", "low")
    tags = fm.get("tags", []) or []
    source = fm.get("source", {}) or {}
    source_key = _source_key(source)

    chunks: list[Chunk] = []
    sections = _split_by_h2(cf.body)
    for sec_idx, (title, text) in enumerate(sections):
        parts = _further_split(text)
        for sub_idx, part in enumerate(parts):
            chunk_id = _chunk_id(
                file_id, sec_idx, sub_idx if len(parts) > 1 else None
            )
            chunks.append(
                Chunk(
                    chunk_id=chunk_id,
                    file_id=file_id,
                    section_index=sec_idx,
                    section_title=title,
                    text=part,
                    domain=domain,
                    topic=topic,
                    subtopic=subtopic,
                    hazard_level=hazard_level,
                    tags=list(tags),
                    source_key=source_key,
                )
            )

    return chunks


def chunk_files(files: list[ContentFile]) -> list[Chunk]:
    all_chunks: list[Chunk] = []
    for cf in files:
        all_chunks.extend(chunk_file(cf))
    return all_chunks
