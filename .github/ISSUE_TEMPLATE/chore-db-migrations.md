---
name: "Chore: DB migrations for queries/presentations/rootcauses"
about: "Add DDL migrations for new tables used by NL→SQL, presentations, and root-cause features"
labels: "chore,backend,infra"
---

## Summary
**Goal:** Add migration files to create `queries`, `query_runs`, `presentations`, and `rootcauses` tables.

## Tasks
- [ ] Create migration SQL files (one per table) under `migrations/`
- [ ] Add tests that run migrations against CI test DB
- [ ] Add docs snippet in `db/schema.md` describing the new tables

## Acceptance Criteria
- Migrations apply cleanly in CI and schema updated docs are present.
