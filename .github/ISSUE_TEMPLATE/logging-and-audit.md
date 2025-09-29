---
name: "Logging, Costing & Token Tracking"
about: "Log LLM prompts/responses, token counts, and cost estimates for auditability and billing"
labels: "chore,infra,security"
---

## Summary
**Goal:** Log all LLM prompts/responses, token counts, and cost estimates. Provide admin UI to view usage per workspace.

## Tasks
- [ ] Add token/cost fields to `queries` and `query_runs` tables
- [ ] Instrument LLM client to capture token usage and approximate cost
- [ ] Emit structured logs for LLM calls (redact PII)
- [ ] Add admin endpoint to view token usage by workspace

## Acceptance Criteria
- Each LLM call logged with `prompt_hash`, `model`, `tokens`, and `approx_cost`
- Admin can view usage grouped by workspace and date
