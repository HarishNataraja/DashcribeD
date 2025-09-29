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
