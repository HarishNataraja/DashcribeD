---
name: "Test: E2E - NL→SQL → Simulate → Slide Export"
about: "E2E test flow to validate the core user journey"
labels: "test,e2e,ci"
---

## Summary
**Goal:** Implement an E2E test that covers NL→SQL translation, simulation of the query, generation of an outline, and slide export.

## Tasks
- [ ] Add a CI job that runs the E2E test using a local test DB or mocked endpoints
- [ ] Script to seed test DB with representative sample data
- [ ] Validate end-to-end artifacts: simulate returns sample rows, PPTX exists and contains expected slides

## Acceptance Criteria
- E2E test passes in CI and artifacts (sample rows, PPTX) are generated in test workspace.
