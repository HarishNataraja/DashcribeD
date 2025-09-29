---
name: "Presentation Outline Agent (Outline-first flow)"
about: "Generate a MECE slide-level outline from a dashboard spec and EDA insights"
labels: "feature,ai,backend"
---

## Summary
**Goal:** Implement `POST /api/v1/presentation/outline` to generate a MECE slide-level outline from a dashboard spec and EDA insights using LLMs.

## Tasks
### Backend
- [ ] Implement `/api/v1/presentation/outline`
- [ ] Load `prompts/presentation_outline_prompt.md` and call LLM
- [ ] Store outline in `presentations` table with status `outline_created`

### Frontend
- [ ] Modal to display outline JSON and allow reorder/edit
- [ ] Approve button to proceed to slide generation

### QA
- [ ] Validate outline JSON schema (`slides[]` with title, bullets, chart_ids)

## Acceptance Criteria
- `/api/v1/presentation/outline` returns a valid `outline_id` and `slides[]` for a dashboard input.
- Frontend displays editable outline and user can approve it.
