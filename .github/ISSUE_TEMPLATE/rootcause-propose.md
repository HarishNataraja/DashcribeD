---
name: "Root-Cause: Hypothesis Generator"
about: "Generate root-cause hypotheses for an insight with validation SQL"
labels: "feature,ai,backend"
---

## Summary
**Goal:** Implement `/api/v1/rootcause/propose` to generate 3 candidate hypotheses for a given insight and produce validation SQL for each.

## Tasks
### Backend
- [ ] Implement `/api/v1/rootcause/propose`
- [ ] Use `prompts/hypothesis_prompt.md` for LLM input and store results in `rootcauses` table

### Frontend
- [ ] UI button 'Run Root Cause' on insight card to open modal listing hypotheses with checkboxes for validation

### QA
- [ ] Manual SME review to ensure hypotheses are actionable and distinct

## Acceptance Criteria
- Endpoint returns 3 distinct hypotheses with at least one validation SQL each and stores them in DB.
