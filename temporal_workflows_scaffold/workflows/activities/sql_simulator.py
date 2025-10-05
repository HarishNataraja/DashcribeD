from temporalio import activity

@activity.defn
async def preview_query(sql: str) -> dict:
    """
    Execute SQL in a sandbox or on sample data, return preview rows and chart spec.
    """
    # TODO: implement DB sandboxing and safe-execution
    # Return structure example:
    return {"sample_rows": [{"col1": 1, "col2": "a"}], "chart_spec": {"type":"table"}}
