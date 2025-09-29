#!/usr/bin/env bash
set -euo pipefail
BRANCH="add/agentic-assets"
COMMIT_MSG="Add agentic AI dev assets: prompts, issue templates, setup and harness"
ROOT="$(pwd)"

echo "Running from repo root: $ROOT"
echo "Creating branch $BRANCH"
git checkout -b "$BRANCH"

# 1) Create .github ISSUE_TEMPLATE files
mkdir -p .github/ISSUE_TEMPLATE

cat > .github/ISSUE_TEMPLATE/nl-sql-show-and-simulate.md <<'MD'
---
name: "Explainable NL→SQL: Show SQL & Simulate-on-Sample"
about: "Feature: Translate NL→SQL, show SQL, provide safety info and simulate query on sample"
labels: "feature,backend,frontend,ai,security"
---

## Summary
**Goal:** Implement explainable NL→SQL flow: translate NL → safe read-only SQL, display SQL and explanation, show safety score & cost estimate, and provide a 'Simulate' action to run the SQL on a sample/read-only replica returning sample rows and a chart preview.

## Tasks
### Backend
- [ ] Add `queries` and `query_runs` tables (DDL migration file)
- [ ] Implement `POST /api/v1/query/translate` (LLM call + SQL validator)
- [ ] Implement `POST /api/v1/query/simulate` (executes on read-only replica or wrapped query with enforced LIMIT/timeouts)
- [ ] Logging: store prompt, response, token usage, and cost estimate in DB

### Frontend
- [ ] Chat/card UI: show AI summary + collapsed SQL accordion
- [ ] Implement Simulate modal: sample rows + chart preview + query plan link
- [ ] Add safety badge & cost estimate callout in UI

### QA & Security
- [ ] Unit tests for SQL validator (forbidden keywords, LIMIT enforcement)
- [ ] Integration tests for translate -> simulate flow (dry mode or mocked DB)
- [ ] Ensure LLM calls redact secrets/PII before sending
- [ ] Use read-only DB credentials for simulation and enforce timeouts

## Acceptance Criteria
- `/api/v1/query/translate` returns JSON with `sql`, `explanation`, `safety_score`, and `cost_estimate` given a valid schema and question.
- SQL validator blocks non-SELECT statements and returns an error for forbidden tokens.
- `/api/v1/query/simulate` returns ≤50 sample rows, `chart_spec`, and `runtime_ms` under configured timeout.
- UI shows SQL accordion, safety badge, and simulation modal with chart preview.
- All outputs are logged in `queries` and `query_runs` tables.
MD

# Additional templates - shortened names, full content can be edited
cat > .github/ISSUE_TEMPLATE/presentation-outline-generator.md <<'MD'
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
MD

cat > .github/ISSUE_TEMPLATE/slide-composer-pptx.md <<'MD'
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
MD

cat > .github/ISSUE_TEMPLATE/provenance-linker.md <<'MD'
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
MD

cat > .github/ISSUE_TEMPLATE/rootcause-propose.md <<'MD'
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
MD

cat > .github/ISSUE_TEMPLATE/rootcause-validate.md <<'MD'
---
name: "Root-Cause: Validation Engine & Stats"
about: "Run validation queries, compute stats, and summarize conclusions & experiments"
labels: "feature,backend,data-science"
---

## Summary
**Goal:** Implement `/api/v1/rootcause/validate` to run selected validation queries in simulate mode, compute statistical tests (t-test, chi2, regression) and produce a summary conclusion & recommended experiments.

## Tasks
### Backend
- [ ] Implement validation endpoint and stats engine (scipy/statsmodels)
- [ ] Summarizer agent to produce human-readable conclusion & experiment recommendation

### Frontend
- [ ] Validation progress UI and results display (sample rows + stats)

### Data Science
- [ ] Unit tests for stats engine correctness

## Acceptance Criteria
- Validation returns `p_value`, `effect_size`, sample size, and a concise `conclusion` and `recommended_action`.
MD

cat > .github/ISSUE_TEMPLATE/logging-and-audit.md <<'MD'
---
name: "Logging, Costing & Token Tracking"
about: "Log LLM prompts/responses, token counts, and cost estimates for auditability and billing"
labels: "chore,infra,security"
---

## Summary
**Goal:** Log all LLM prompts/responses, token counts, and cost estimates. Provide admin UI to view usage per workspace.

## Tasks
- [ ] Add token/cost fields to `queries` and `query_runs` tables
- [ ] Instrument LLM client to capture token usage and approximate cost
- [ ] Emit structured logs for LLM calls (redact PII)
- [ ] Add admin endpoint to view token usage by workspace

## Acceptance Criteria
- Each LLM call logged with `prompt_hash`, `model`, `tokens`, and `approx_cost`
- Admin can view usage grouped by workspace and date
MD

cat > .github/ISSUE_TEMPLATE/nl-sql-validator-tests.md <<'MD'
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
MD

cat > .github/ISSUE_TEMPLATE/chore-db-migrations.md <<'MD'
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
MD

cat > .github/ISSUE_TEMPLATE/pr-llm-wrapper.md <<'MD'
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
MD

cat > .github/ISSUE_TEMPLATE/presentation-ux.md <<'MD'
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
MD

cat > .github/ISSUE_TEMPLATE/test-e2e-template.md <<'MD'
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
MD

# 2) Create prompts folder and files
mkdir -p prompts

cat > prompts/nl_to_sql_system.md <<'MD'
SYSTEM MESSAGE - NL→SQL AGENT (SAFETY-FIRST)
You are a safe, conservative SQL generator used to translate clear user intents into READ-ONLY SELECT queries.
Rules:
1. Output ONLY a JSON object. Use one of:
   - {"sql":"<SQL_QUERY>", "explanation":"<one-sentence explanation>"}
   - {"clarify":"<one short clarifying question>"}
2. Never output DDL or DML (INSERT, UPDATE, DELETE, DROP, ALTER, TRUNCATE). If intent asks to modify data, reply with a clarify question.
3. Use only tables and columns provided in the `Schema:` input. Do not invent tables/columns.
4. Add a default `LIMIT 1000` unless user explicitly requests more.
5. Avoid cartesian joins; always use explicit JOIN ... ON clauses where multiple tables are referenced.
6. If aggregates are present, include non-aggregated columns in `GROUP BY`.
7. Parameterize user inputs where possible (use placeholders) — the system will bind parameters server-side.
8. For ambiguous time ranges or periods, ask one clarifying question.
9. If the dataset is large, provide a simple `preview_query` suggestion (LIMIT 50 sample).
10. Output SQL should be compatible with PostgreSQL dialect by default unless `dialect` is specified.
MD

cat > prompts/nl_to_sql_user_examples.md <<'MD'
### Example 1 (Time-series aggregation)
User: "Show monthly revenue for 2024 by region."
Schema: orders(order_id, order_date, revenue, region)
Output:
{"sql":"SELECT DATE_TRUNC('month', order_date) AS month, region, SUM(revenue) AS total_revenue FROM orders WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01' GROUP BY month, region ORDER BY month LIMIT 1000;","explanation":"Monthly revenue by region for 2024."}

### Example 2 (Join)
User: "Top 10 products by revenue in Q1 2025 with product names."
Schema: sales(sale_id, sale_date, product_id, revenue), products(product_id, product_name)
Output:
{"sql":"SELECT p.product_name, SUM(s.revenue) AS total_revenue FROM sales s JOIN products p ON s.product_id = p.product_id WHERE s.sale_date >= '2025-01-01' AND s.sale_date < '2025-04-01' GROUP BY p.product_name ORDER BY total_revenue DESC LIMIT 10;","explanation":"Top 10 products by revenue in Q1 2025 with names."}

### Example 3 (Ambiguous)
User: "Give me revenue by channel"
Schema: transactions(txn_id, txn_date, revenue, channel)
Output:
{"clarify":"Which time period would you like (e.g., last 30 days, year-to-date)? Also, do you want total or average revenue per channel?"}
MD

cat > prompts/eda_agent_prompt.md <<'MD'
SYSTEM MESSAGE — EDA AGENT
You are an expert data analyst. Given a dataset summary (columns, types, sample statistics), return a JSON object with these keys:
{
 "summary": "<2-3 sentence executive summary>",
 "charts": [ {"column":"", "chart":"histogram/line/box/bar", "rationale":""} ],
 "missingness": [ {"column":"", "missing_pct":0.0, "suggestion":"drop/impute/fill"} ],
 "correlations": [ {"pair":["colA","colB"], "corr":0.52, "note":""} ],
 "anomalies": [ {"column":"", "row_example":{...}, "note":""} ]
}
Rules:
- Do not invent numeric values beyond the provided sample stats.
- Recommend chart types and a one-line rationale for each.
- Provide at least one suggested next analytical step.
MD

cat > prompts/presentation_outline_prompt.md <<'MD'
SYSTEM MESSAGE — PRESENTATION OUTLINE AGENT
You are an expert strategy consultant and slide-writer. Given a dashboard spec and EDA insights, produce a slide-level JSON outline for a 6-slide board meeting deck.
Return:
{
 "slides":[ {"index":0,"title":"", "bullets":["..."], "chart_ids":[...]} ],
 "notes": { "0":"speaker notes..." }
}
Rules:
- Use MECE structure.
- For each slide include suggested chart_ids from the dashboard spec.
- Keep bullet text concise (max 18 words each).
- Provide speaker notes per slide (1–2 sentences).
MD

# 3) Create setup.sh and Makefile
cat > setup.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
echo "Setting up Agentic AI Dev Assets environment..."
python3 -m venv .venv || python -m venv .venv
. .venv/bin/activate
pip install --upgrade pip
pip install openai sqlparse python-dotenv sqlparse
echo "Dependencies installed. To run harness:"
echo "  export OPENAI_API_KEY=sk-..."
echo "  python agentic_ai_dev_assets_extra/prompt_testing_harness.py --mode dry --sql 'SELECT 1' --schema 'orders(id,date)'"
SH
chmod +x setup.sh

cat > Makefile <<'MF'
.PHONY: setup deps run-live run-dry

deps:
	python3 -m venv .venv || python -m venv .venv
	. .venv/bin/activate; pip install --upgrade pip; pip install openai sqlparse python-dotenv

run-dry:
	. .venv/bin/activate; python -c "print('dry run placeholder')"
MF

# 4) Commit & push
git add .
git commit -m "$COMMIT_MSG"
git push -u origin "$BRANCH"

# 5) Try to open a PR with gh if available
if command -v gh >/dev/null 2>&1; then
  echo "Opening PR via gh..."
  gh pr create --fill --title "$COMMIT_MSG" --body "Adds agentic ai dev assets, prompts and issue templates."
else
  echo "gh CLI not found. Branch pushed as $BRANCH. Create a PR in GitHub UI."
fi

echo "Done. Branch: $BRANCH. Review changes and open PR."
