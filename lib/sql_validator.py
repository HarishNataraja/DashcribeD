import re

FORBIDDEN = ["insert ", "update ", "delete ", "drop ", "alter ", "truncate "]

def is_safe_sql(sql: str, require_limit=True):
    s = sql.strip().lower()
    if not s.startswith("select"):
        return False, "Not a SELECT statement"
    for f in FORBIDDEN:
        if f in s:
            return False, f"Forbidden statement detected: {f.strip()}"
    if require_limit and "limit" not in s:
        return False, "Missing LIMIT clause"
    # detect naive cartesian join: 'from a, b' or 'from a b' without on — this is heuristic
    if re.search(r"from\s+[a-z0-9_]+\s*,\s*[a-z0-9_]+", s):
        return False, "Possible cartesian join detected"
    return True, "OK"