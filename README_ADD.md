# Agentic AI Assets — added files

This folder adds:
- prompts/: prompt templates (NL->SQL, EDA, presentation outline)
- agentic_ai_dev_assets_extra/prompt_testing_harness.py: harness to test LLM prompts (live/dry)
- services/: llm_client, nl_sql_service, slide_composer, rootcause_service
- lib/sql_validator.py: simple SQL safety checks
- migrations/: migration SQL to add queries/presentations/rootcauses tables
- tests/: basic unit tests for validator & stats engine

Quick usage:
1. Install deps: `pip install -r requirements.txt` (or run `./setup.sh`)
2. Run prompt harness (dry): `python agentic_ai_dev_assets_extra/prompt_testing_harness.py --mode dry --sql "SELECT 1 LIMIT 1" --schema "orders(order_id)"`
3. Run tests: `pytest -q`