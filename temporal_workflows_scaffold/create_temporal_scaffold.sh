#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(pwd)/temporal_workflows_scaffold"
rm -rf "$ROOT_DIR"
mkdir -p "$ROOT_DIR"

# create folders
mkdir -p "$ROOT_DIR/workflows/activities"

# write files
cat > "$ROOT_DIR/workflows/__init__.py" <<'PY'
# workflows package
PY

cat > "$ROOT_DIR/workflows/activities/__init__.py" <<'PY'
# activities package
PY

cat > "$ROOT_DIR/workflows/chat_to_slide_workflow.py" <<'PY'
from temporalio import workflow
import workflows.activities.nl_to_sql as nl_to_sql
import workflows.activities.sql_simulator as sql_simulator
import workflows.activities.eda as eda
import workflows.activities.outline as outline
import workflows.activities.slide_composer as slide_composer
import workflows.activities.export as export

@workflow.defn
class ChatToSlideWorkflow:
    @workflow.run
    async def run(self, query: str, schema: str, workspace_id: str) -> str:
        # 1. Generate SQL
        sql = await workflow.execute_activity(nl_to_sql.generate_sql, query, schema, start_to_close_timeout=30)
        # 2. Preview / simulate SQL
        preview = await workflow.execute_activity(sql_simulator.preview_query, sql, start_to_close_timeout=60)
        # 3. Run EDA
        eda_report = await workflow.execute_activity(eda.run_eda, preview, start_to_close_timeout=120)
        # 4. Draft outline
        outline_json = await workflow.execute_activity(outline.draft_outline, eda_report, start_to_close_timeout=60)
        # 5. Compose slides
        pptx_path = await workflow.execute_activity(slide_composer.compose, outline_json, start_to_close_timeout=120)
        # 6. Export and get signed URL
        signed_url = await workflow.execute_activity(export.upload_and_get_url, pptx_path, workspace_id, start_to_close_timeout=60)
        return signed_url
PY

cat > "$ROOT_DIR/workflows/text_to_visual_workflow.py" <<'PY'
from temporalio import workflow
import workflows.activities.text_parse as text_parse
import workflows.activities.viz_decider as viz_decider
import workflows.activities.component_gen as component_gen
import workflows.activities.export as export

@workflow.defn
class TextToVisualWorkflow:
    @workflow.run
    async def run(self, text: str, workspace_id: str) -> str:
        parsed = await workflow.execute_activity(text_parse.parse, text, start_to_close_timeout=60)
        viz_type = await workflow.execute_activity(viz_decider.choose_type, parsed, start_to_close_timeout=30)
        canvas_spec = await workflow.execute_activity(component_gen.build, parsed, viz_type, start_to_close_timeout=90)
        signed_url = await workflow.execute_activity(export.upload_and_get_url, canvas_spec, workspace_id, start_to_close_timeout=60)
        return signed_url
PY

# Activities
cat > "$ROOT_DIR/workflows/activities/ingest.py" <<'PY'
from temporalio import activity

@activity.defn
async def ingest_source(source_descriptor: dict) -> dict:
    """
    Ingest data from a source.
    source_descriptor could include type: 'csv'|'excel'|'db', path or connection details.
    Returns a dict with keys: schema, sample_rows_path, fingerprint
    """
    # TODO: implement ingestion logic (parsers, connectors)
    return {"schema": {}, "sample_rows_path": "/tmp/sample.csv", "fingerprint": "sha1-..."}
PY

cat > "$ROOT_DIR/workflows/activities/nl_to_sql.py" <<'PY'
from temporalio import activity

@activity.defn
async def generate_sql(nl_query: str, schema: str) -> str:
    """
    Call NL->SQL agent to generate a safe, read-only SQL string.
    """
    # TODO: integrate with LLM client / NL->SQL service
    # Example stub:
    return "SELECT * FROM example_table LIMIT 50;"
PY

cat > "$ROOT_DIR/workflows/activities/sql_simulator.py" <<'PY'
from temporalio import activity

@activity.defn
async def preview_query(sql: str) -> dict:
    """
    Execute SQL in a sandbox or on sample data, return preview rows and chart spec.
    """
    # TODO: implement DB sandboxing and safe-execution
    # Return structure example:
    return {"sample_rows": [{"col1": 1, "col2": "a"}], "chart_spec": {"type":"table"}}
PY

cat > "$ROOT_DIR/workflows/activities/eda.py" <<'PY'
from temporalio import activity

@activity.defn
async def run_eda(preview: dict) -> dict:
    """
    Run automated EDA on sample_rows or a query result and return structured insights.
    """
    # TODO: implement numeric summaries, missingness, correlations, anomalies, charts
    return {"summary":"EDA summary placeholder", "charts": [], "insights": []}
PY

cat > "$ROOT_DIR/workflows/activities/outline.py" <<'PY'
from temporalio import activity

@activity.defn
async def draft_outline(eda_report: dict) -> dict:
    """
    Produce a slide-level outline (MECE-like) from EDA insights.
    """
    # TODO: call presentation outline agent / LLM
    return {"slides":[{"index":0,"title":"Executive Summary","bullets":["Key insight 1","Key insight 2"], "chart_ids": []}], "notes": {}}
PY

cat > "$ROOT_DIR/workflows/activities/slide_composer.py" <<'PY'
from temporalio import activity

@activity.defn
async def compose(outline_json: dict) -> str:
    """
    Create PPTX from outline and return local path to PPTX file.
    """
    # TODO: render charts, embed images, create PPTX with python-pptx
    out_path = "/tmp/generated_presentation.pptx"
    # create placeholder file
    with open(out_path, "wb") as f:
        f.write(b"PK\\x03\\x04")  # minimal ZIP/PPTX header stub (not a valid PPTX)
    return out_path
PY

cat > "$ROOT_DIR/workflows/activities/text_parse.py" <<'PY'
from temporalio import activity

@activity.defn
async def parse(text: str) -> dict:
    """
    Parse free text and return structured representation:
    {title, steps[], bullets[], entities[], numeric_table[]}
    """
    # TODO: use LLM or spaCy to extract structure
    return {"title":"Parsed Title", "steps":["Step 1","Step 2"], "entities":[], "numeric_table":[]}
PY

cat > "$ROOT_DIR/workflows/activities/viz_decider.py" <<'PY'
from temporalio import activity

@activity.defn
async def choose_type(parsed: dict) -> str:
    """
    Decide best visualization given parsed content. Return viz_type e.g. 'bar','flowchart','mindmap'
    """
    # Simple rule-based stub:
    if parsed.get("numeric_table"):
        return "chart"
    if parsed.get("steps"):
        return "flowchart"
    return "diagram"
PY

cat > "$ROOT_DIR/workflows/activities/component_gen.py" <<'PY'
from temporalio import activity

@activity.defn
async def build(parsed: dict, viz_type: str) -> dict:
    """
    Build canvas/spec for the chosen visualization. Return a canvas spec that can be rendered.
    """
    # TODO: generate chart specs (Vega/Vega-Lite/Plotly) or diagram node/edge lists
    return {"viz_type": viz_type, "spec": {"nodes":[], "edges":[]}, "assets": []}
PY

cat > "$ROOT_DIR/workflows/activities/export.py" <<'PY'
from temporalio import activity

@activity.defn
async def upload_and_get_url(artifact, workspace_id: str) -> str:
    """
    Upload artifact (pptx/svg/json) to object storage and return a signed URL.
    """
    # TODO: integrate with S3/GCS and return pre-signed URL
    return "https://example.com/download/artifact.pptx?signature=stub"
PY

# worker runner
cat > "$ROOT_DIR/worker_run.py" <<'PY'
"""
Temporal worker runner - registers workflows and activities.
Run this in a container to start a worker that polls Temporal.
"""
import asyncio
from temporalio.client import Client
from temporalio.worker import Worker
import workflows.chat_to_slide_workflow as chat_workflow
import workflows.text_to_visual_workflow as text_workflow

async def run_worker():
    client = await Client.connect("temporal:7233")
    worker = Worker(
        client,
        task_queue="agentic-task-queue",
        workflows=[chat_workflow.ChatToSlideWorkflow, text_workflow.TextToVisualWorkflow],
        activities=[
            # Provide activity callables by importing them here if needed
        ],
    )
    await worker.run()

if __name__ == '__main__':
    asyncio.run(run_worker())
PY

# README
cat > "$ROOT_DIR/README.md" <<'MD'
# Temporal Workflows Scaffold for Agentic Platform

This scaffold contains workflow definitions and activity skeletons for the Agentic Analytics & Presentation platform.
Files created under this folder are stubs intended to be extended and wired to actual services/agents.

**How to use**:
- Implement the TODOs in each activity (call your services / LLM clients / DBs)
- Deploy a Temporal cluster (or use Temporal Cloud)
- Build a worker container that runs `worker_run.py` and registers workflows/activities.

MD

# requirements.txt
cat > "$ROOT_DIR/requirements.txt" <<'TXT'
temporalio==1.6.0
# add your other dependencies: openai, sqlalchemy, boto3, pandas, python-pptx, etc.
TXT

# Zip the scaffold
ZIP_PATH="$(pwd)/temporal_workflows_scaffold.zip"
rm -f "$ZIP_PATH"
( cd "$(pwd)" && zip -r "$ZIP_PATH" "$(basename "$ROOT_DIR")" > /dev/null )

echo "Scaffold created at: $ROOT_DIR"
echo "ZIP created at: $ZIP_PATH"
