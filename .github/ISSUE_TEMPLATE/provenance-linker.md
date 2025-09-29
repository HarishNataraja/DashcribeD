---
name: "Slide Provenance: link slides → charts → SQL"
about: "Ensure each slide contains provenance linking to chart and SQL"
labels: "feature,backend,ux"
---

## Summary
**Goal:** Each generated slide should include provenance: chart_id(s), SQL for those charts, and a deep-link back to the dashboard view.

## Tasks
### Backend
- [ ] Update slide meta JSON structure to include chart -> SQL mapping
- [ ] Ensure composer populates provenance for every slide

### Frontend
- [ ] In slide editor/notes, show 'View Source' link that opens the dashboard and highlights the chart

### QA
- [ ] Validate every slide contains `chart_id` and `sql` in metadata
- [ ] Clicking 'View Source' navigates to the dashboard and highlights the chart

## Acceptance Criteria
- Slides metadata includes chart->SQL mapping and frontend deep-link works.
