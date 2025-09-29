---
name: "Slide Composer & PPTX Export (MVP)"
about: "Compose slides and export PPTX with embedded chart images and speaker notes"
labels: "feature,backend,frontend,integration"
---

## Summary
**Goal:** Assemble slides from an approved outline and selected charts, export a `.pptx` with embedded chart images and speaker notes, and store presentation metadata.

## Tasks
### Backend
- [ ] Implement `/api/v1/presentation/generate` to assemble slides
- [ ] Server-side chart PNG generator (Plotly -> PNG)
- [ ] Integrate `python-pptx` to create slides with embedded PNGs and speaker notes
- [ ] Upload final PPT to S3 and store `presentations.s3_url`

### Frontend
- [ ] Progress UI displaying thumbnails as slides are generated
- [ ] Download button for `.pptx`

### QA
- [ ] Automated tests: generated PPT contains expected slide count and non-empty speaker notes
- [ ] Manual review of template by product designer

## Acceptance Criteria
- `/api/v1/presentation/generate` produces a PPTX with embedded chart images and speaker notes and saves metadata in `presentations` table.
