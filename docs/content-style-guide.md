# Content Style Guide

How to write a chunk for a knowledge pack.

## File layout

One Markdown file per topic, in the right domain folder:

```
packs/camping/content/<domain>/<topic-kebab-case>.md
```

Domains: `first-aid`, `knots`, `water`, `shelter`, `fire`, `navigation`, `wildlife`, `plants`, `weather`, `food`, `gear-fixes`, `trip-basics`.

## File structure

Every file has YAML frontmatter, then Markdown content split by `##` headings. The chunker emits one chunk per `##` section.

```markdown
---
id: water.boil-purification
domain: water
topic: purification
subtopic: boiling
hazard_level: medium       # low | medium | high | critical
tags: [water, purification, boiling, giardia]
source:
  title: "Drinking Water Treatment in Emergencies"
  publisher: "U.S. CDC"
  url: "https://www.cdc.gov/healthywater/emergency/drinking/making-water-safe.html"
  license: public-domain   # public-domain | cc-by | cc-by-sa | quoted-fair-use | author
  retrieved_at: 2026-05-16
status: draft               # draft | reviewed | sme_approved
last_reviewed: 2026-05-16
---

# Boiling Water for Purification

## When to boil
Boiling is the most reliable method for killing pathogens in water...

## How to boil
1. Bring water to a rolling boil for at least 1 minute (3 minutes above 6,500 ft / 2,000 m).
2. Let it cool naturally — do not add ice from an untreated source.
3. Improve flat taste by pouring between two containers or adding a pinch of salt.

## Limits
Boiling does not remove chemical contaminants, heavy metals, or radiological hazards...
```

## Chunk rules

1. **One idea per chunk** — split into multiple `##` sections if a topic covers distinct ideas.
2. **~300 words max per section** (~1500 chars). Long sections retrieve poorly.
3. **Self-contained** — a chunk should make sense without reading the surrounding file.
4. **Concrete, not philosophical** — "boil for 1 minute" beats "consider boiling."

## Voice + safety

1. **Conservative**: always defer to professionals when relevant. Add a final sentence like _"If symptoms worsen or you have any doubt, seek emergency medical help."_
2. **No dosages** in v1 — describe what to do, never how much medication to take.
3. **No edibility assertions** — never write "this plant is safe to eat." Always frame as identification + caution.
4. **Cite freshness** — `last_reviewed` is a real date, not a placeholder. Outdoor knowledge changes (bear behavior research, first aid protocols evolve).

## Frontmatter field reference

| Field           | Required | Notes                                                  |
|-----------------|----------|--------------------------------------------------------|
| `id`            | yes      | `<domain>.<slug>` — unique across the pack             |
| `domain`        | yes      | Must match folder name                                 |
| `topic`         | yes      | Free-form, short                                       |
| `subtopic`      | no       | Free-form, finer-grained                               |
| `hazard_level`  | yes      | `low` / `medium` / `high` / `critical`                 |
| `tags`          | yes      | List of lowercase keywords                             |
| `source`        | yes      | Object with `title`, `publisher`, `url`, `license`     |
| `status`        | yes      | `draft` / `reviewed` / `sme_approved`                  |
| `last_reviewed` | yes      | ISO date                                               |

## Source-license preference order

1. Public domain (CDC, NPS, USFS, NOAA, USCG, military field manuals where applicable)
2. Permissive open-licensed wilderness medicine references (cite carefully)
3. Author-paraphrased with attribution
4. ❌ Never copy-paste copyrighted content
