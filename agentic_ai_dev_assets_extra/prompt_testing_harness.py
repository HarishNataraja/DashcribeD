#!/usr/bin/env python3
"""
Prompt Testing Harness for NL->SQL Agent (live + dry)

Usage:
  pip install openai sqlparse python-dotenv
  export OPENAI_API_KEY="sk-..."
  python prompt_testing_harness.py --mode live --question "Top 5 products by revenue in Q1 2025." --schema "sales(sale_id, sale_date, product_id, revenue);products(product_id, product_name)"
  python prompt_testing_harness.py --mode dry --sql "SELECT 1" --schema "orders(id,date)"
"""

import os
import argparse
import json
import re
from pathlib import Path
import sqlparse

PROMPTS_DIR = Path("prompts")
FEWSHOT_FILE = PROMPTS_DIR / "nl_to_sql_user_examples.md"
SYSTEM_FILE = PROMPTS_DIR / "nl_to_sql_system.md"

def load_prompt(path: Path):
    if not path.exists():
        raise FileNotFoundError(f"{path} not found")
    return path.read_text()

def validate_sql(sql_text: str, schema_cols: dict):
    sql_clean = sql_text.strip().rstrip(";") + ";"
    lower = sql_clean.lower()
    if not lower.strip().startswith("select"):
        return False, "SQL must start with SELECT"
    if "insert " in lower or "update " in lower or "delete " in lower or "drop " in lower or "alter " in lower or "truncate " in lower:
        return False, "Forbidden statements detected"
    # require LIMIT for safety (unless user requested no-limit)
    if "limit" not in lower:
        return False, "Missing LIMIT clause"
    # basic identifier check
    ids = set(re.findall(r"[a-zA-Z_][a-zA-Z0-9_]*", sql_clean))
    allowed = set()
    for tbl, cols in schema_cols.items():
        allowed.add(tbl)
        allowed.update(cols)
    # allow common SQL keywords/functions
    keywords = {"select","from","where","group","by","order","limit","and","or","as","on","join","inner","left","right","full","outer","over","partition","row_number","sum","count","avg","min","max","date_trunc","generate_series"}
    bad = ids - allowed - keywords
    if bad:
        # this is permissive — warn rather than hard fail
        return False, f"Found identifiers not in provided schema: {sorted(bad)}"
    return True, "OK"

def call_llm(prompt_text: str):
    import openai
    api_key = os.environ.get("OPENAI_API_KEY") or ""
    if not api_key:
        raise EnvironmentError("OPENAI_API_KEY not set for live mode.")
    openai.api_key = api_key
    resp = openai.ChatCompletion.create(model="gpt-4o-mini", messages=[{"role":"user","content":prompt_text}], max_tokens=800)
    return resp['choices'][0]['message']['content']

def extract_json(text: str):
    m = re.search(r"\{.*\}", text, re.S)
    if not m:
        raise ValueError("No JSON object found in model output")
    return json.loads(m.group(0))

def run_live(question: str, schema: str, schema_cols: dict):
    system = load_prompt(SYSTEM_FILE)
    few = load_prompt(FEWSHOT_FILE) if FEWSHOT_FILE.exists() else ""
    user_block = f'User: "{question}"\nSchema: {schema}\n'
    full_prompt = system + "\n\n" + few + "\n\n" + user_block + "\nPlease output JSON as specified."
    print("SENDING PROMPT (truncated):")
    print(full_prompt[:1200] + "...\n")
    out = call_llm(full_prompt)
    print("LLM OUTPUT:")
    print(out)
    j = extract_json(out)
    sql = j.get("sql")
    valid, msg = validate_sql(sql, schema_cols) if sql else (False, "No SQL returned")
    print("VALIDATION:", valid, msg)
    return j, valid, msg

def run_dry(sql: str, schema_cols: dict):
    ok, msg = validate_sql(sql, schema_cols)
    print("DRY VALIDATION:", ok, msg)
    return ok, msg

def parse_schema(schema_str: str):
    schema_cols = {}
    for part in schema_str.split(";"):
        part = part.strip()
        if not part:
            continue
        m = re.match(r"([a-zA-Z0-9_]+)\((.*?)\)", part)
        if not m:
            continue
        tbl = m.group(1)
        cols = {c.strip() for c in m.group(2).split(",") if c.strip()}
        schema_cols[tbl] = cols
    return schema_cols

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--mode", choices=["live","dry"], required=True)
    p.add_argument("--question", type=str, default="Show monthly revenue for 2024 by region.")
    p.add_argument("--schema", type=str, default="orders(order_id, order_date, revenue, region)")
    p.add_argument("--sql", type=str, default="")
    args = p.parse_args()

    schema_cols = parse_schema(args.schema)
    if args.mode == "live":
        j, ok, msg = run_live(args.question, args.schema, schema_cols)
        print(json.dumps(j, indent=2))
    else:
        run_dry(args.sql, schema_cols)