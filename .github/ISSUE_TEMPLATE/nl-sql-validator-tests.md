---
name: "Unit tests for SQL Validator"
about: "Add unit tests for SQL validator rules"
labels: "test,backend"
---

## Summary
**Goal:** Add unit tests to validate SQL validator rejects DML/DDL, ensures LIMIT present, and detects cross-join patterns.

## Tasks
- [ ] Add tests for rejection of INSERT/UPDATE/DELETE/DROP/ALTER
- [ ] Add tests ensuring LIMIT enforcement where required
- [ ] Add tests detecting naive cartesian joins
- [ ] Add tests for allowed function names

## Acceptance Criteria
- All validator tests pass in CI
