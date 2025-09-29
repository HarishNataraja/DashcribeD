---
name: "Chore: LLM client wrapper & token tracking"
about: "Create a central LLM client wrapper to capture token counts and handle retries/errors"
labels: "chore,backend,infra"
---

## Summary
**Goal:** Implement a wrapper around LLM provider calls to capture token usage, approximate cost, and standardize retry behavior.

## Tasks
- [ ] Add `services/llm_client.py` wrapper
- [ ] Capture prompt hash, model name, tokens used, and response time
- [ ] Expose metrics for admin UI and include in `queries` logging

## Acceptance Criteria
- All LLM calls in the app use wrapper and token usage is logged per-call.
