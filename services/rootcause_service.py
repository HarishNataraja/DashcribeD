"""
Root-cause service skeleton.
- propose hypotheses using LLM
- validate using SQL (simulate) and run statistics via scipy
"""
from services.llm_client import LLMClient
llm = LLMClient()

def propose_hypotheses(insight: dict, context: dict):
    prompt = f"You are a data scientist. Metric change: {insight}. Context: {context}\nPropose 3 hypotheses and for each provide 1-2 validation SQL queries (read-only). Return JSON."
    resp = llm.call([{"role":"user","content":prompt}])
    import re, json
    m = re.search(r"\{.*\}", resp["response"], re.S)
    if not m:
        raise ValueError("No JSON")
    return json.loads(m.group(0))

def validate_query_stats(query_results):
    # placeholder: run t-test / chi2 etc on query_results using scipy.stats
    from scipy import stats
    # user will implement appropriate tests; return sample values
    return {"p_value": 0.05, "effect_size": 0.2}