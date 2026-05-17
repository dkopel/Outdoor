# Safety Rules Specification

`safety_rules.yaml` defines how the app handles queries by intent. It is per-pack data, not code — adding a new pack means writing a new ruleset, not changing the app.

## Goals

- High-risk content (first aid, edible plants/animals) **never** goes through freeform LLM generation
- Every answer in a risky domain includes a "must include" safety statement
- "Refuse with warning" is a first-class output

## Schema

```yaml
- intent: <string>           # canonical intent name (snake_case)
  match: [<keyword>, ...]    # case-insensitive substring or regex; ordered by priority
  risk: <low|medium|high|critical>
  answer_mode: <mode>
  must_include: [<string>, ...]   # text appended to every answer
  refuse_patterns: [<pattern>, ...]  # if matched, refuse outright
  redirect: <pack_id|null>   # suggest a different pack (post-MVP hook)
```

## `answer_mode` values

| Mode                       | LLM used?       | What renders                                          |
|----------------------------|-----------------|-------------------------------------------------------|
| `rag_freeform`             | yes             | LLM summarizes retrieved chunks (default for low risk) |
| `rag_with_safety_appendix` | yes, constrained| LLM answer + locked "must_include" safety block appended |
| `locked_procedure`         | no              | Renders a procedure card directly from `procedures` table |
| `refuse_with_warning`      | no              | Hardcoded refusal + safety statement                  |
| `redirect_pack`            | no              | "This isn't in your camping pack — try the Wilderness Medicine pack" |

## Intent matching

The SafetyRouter runs in order:

1. Tokenize + lowercase the user query
2. For each rule (in file order), check if any `match` keyword/regex hits
3. First match wins — order rules from most specific to least
4. If no rule matches, default to `rag_freeform`
5. Check `refuse_patterns` AFTER an `answer_mode` is chosen — if any refuse pattern hits, force `refuse_with_warning`

## Standard intents (camping pack)

- `first_aid` → `locked_procedure`
- `cpr_resuscitation` → `locked_procedure`
- `plant_id_edibility` → `refuse_with_warning`
- `animal_id_edibility` → `refuse_with_warning`
- `medication_dosage` → `refuse_with_warning`
- `animal_encounter` → `rag_with_safety_appendix`
- `lightning_storm` → `rag_with_safety_appendix`
- `lost_or_rescue` → `rag_with_safety_appendix`
- (anything else) → `rag_freeform`

## Refuse patterns (always refuse)

Regardless of intent, these always force `refuse_with_warning`:

- "what dose of X" / "how much X should I take"
- "is this safe to eat" / "can I eat"
- "diagnose" / "what disease does my friend have"
- "should I go" (binary route-safety) — refuse and redirect to general guidance

## Future: signed safety rules

Post-MVP, `safety_rules.yaml` will be signed alongside the pack manifest so the app can verify rules haven't been tampered with after build.
