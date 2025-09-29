---
name: "Explainable NL→SQL: Show SQL & Simulate-on-Sample"
about: "Feature: Translate NL→SQL, show SQL, provide safety info and simulate query on sample"
labels: "feature,backend,frontend,ai,security"
---

## Summary
**Goal:** Implement explainable NL→SQL flow: translate NL → safe read-only SQL, display SQL and explanation, show safety score & cost estimate, and provide a 'Simulate' action to run the SQL on a sample/read-only replica returning sample rows and a chart preview.

## Tasks
### Backend
- [ ] Add `queries` and `query_runs` tables (DDL migration file)
- [ ] Implement `POST /api/v1/query/translate` (LLM call + SQL validator)
- [ ] Implement `POST /api/v1/query/simulate` (executes on read-only replica or wrapped query with enforced LIMIT/timeouts)
- [ ] Logging: store prompt, response, token usage, and cost estimate in DB

### Frontend
- [ ] Chat/card UI: show AI summary + collapsed SQL accordion
- [ ] Implement Simulate modal: sample rows + chart preview + query plan link
- [ ] Add safety badge & cost estimate callout in UI

### QA & Security
- [ ] Unit tests for SQL validator (forbidden keywords, LIMIT enforcement)
- [ ] Integration tests for translate -> simulate flow (dry mode or mocked DB)
- [ ] Ensure LLM calls redact secrets/PII before sending
- [ ] Use read-only DB credentials for simulation and enforce timeouts

## Acceptance Criteria
- `/api/v1/query/translate` returns JSON with `sql`, `explanation`, `safety_score`, and `cost_estimate` given a valid schema and question.
- SQL validator blocks non-SELECT statements and returns an error for forbidden tokens.
- `/api/v1/query/simulate` returns ≤50 sample rows, `chart_spec`, and `runtime_ms` under configured timeout.
- UI shows SQL accordion, safety badge, and simulation modal with chart preview.
- All outputs are logged in `queries` and `query_runs` tables.
