---
name: "UX: Presentation Editor & WYSIWYG improvements"
about: "Build a WYSIWYG slide editor for light editing of AI-generated slides"
labels: "ux,frontend,feature"
---

## Summary
**Goal:** Provide a minimal WYSIWYG editor for slides so users can adjust headlines, swap charts, and edit speaker notes before export.

## Tasks
- [ ] Implement slide canvas with ability to edit text and replace charts
- [ ] Thumbnail strip and drag-to-reorder slides
- [ ] Save edits to `presentations.slides` JSON and re-generate export

## Acceptance Criteria
- Users can edit slide headline, bullets, and notes in the editor and saved changes are reflected in the exported PPTX.
