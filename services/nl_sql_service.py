"""
NL->SQL service skeleton:
- loads system prompt from prompts/nl_to_sql_system.md
- calls LLM via services.llm_client.LLMClient
- validates sql via lib.sql_validator
- logs into DB via a placeholder function (implement DB writes)
"""
from pathlib import Path
from services.llm_client import LLMClient
from lib.sql_validator import is_safe_sql

PROMPT_FILE = Path("prompts/nl_to_sql_system.md")
FEWSHOT_FILE = Path("prompts/nl_to_sql_user_examples.md")

llm = LLMClient()

def load_prompts():
    system = PROMPT_FILE.read_text() if PROMPT_FILE.exists() else ""
    few = FEWSHOT_FILE.read_text() if FEWSHOT_FILE.exists() else ""
    return system, few

def translate(question: str, schema: str, dialect="postgres"):
    system, few = load_prompts()
    messages = [
        {"role":"system", "content": system},
        {"role":"user", "content": few + "\n\n" + f"User: \"{question}\"\nSchema: {schema}\nPlease output JSON as specified."}
    ]
    resp = llm.call(messages)
    # parse resp['response'] expecting JSON object
    import json, re
    m = re.search(r"\{.*\}", resp["response"], re.S)
    if not m:
        raise ValueError("LLM did not return JSON")
    j = json.loads(m.group(0))
    sql = j.get("sql")
    if not sql:
        return j
    safe, msg = is_safe_sql(sql)
    j["safety"] = {"safe": safe, "msg": msg}
    # TODO: store in DB via queries table
    return j