from temporalio import activity

@activity.defn
async def generate_sql(nl_query: str, schema: str) -> str:
    """
    Call NL->SQL agent to generate a safe, read-only SQL string.
    """
    # TODO: integrate with LLM client / NL->SQL service
    # Example stub:
    return "SELECT * FROM example_table LIMIT 50;"
