---
name: "Root-Cause: Validation Engine & Stats"
about: "Run validation queries, compute stats, and summarize conclusions & experiments"
labels: "feature,backend,data-science"
---

## Summary
**Goal:** Implement `/api/v1/rootcause/validate` to run selected validation queries in simulate mode, compute statistical tests (t-test, chi2, regression) and produce a summary conclusion & recommended experiments.

## Tasks
### Backend
- [ ] Implement validation endpoint and stats engine (scipy/statsmodels)
- [ ] Summarizer agent to produce human-readable conclusion & experiment recommendation

### Frontend
- [ ] Validation progress UI and results display (sample rows + stats)

### Data Science
- [ ] Unit tests for stats engine correctness

## Acceptance Criteria
- Validation returns `p_value`, `effect_size`, sample size, and a concise `conclusion` and `recommended_action`.
