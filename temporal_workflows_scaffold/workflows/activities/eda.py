from temporalio import activity

@activity.defn
async def run_eda(preview: dict) -> dict:
    """
    Run automated EDA on sample_rows or a query result and return structured insights.
    """
    # TODO: implement numeric summaries, missingness, correlations, anomalies, charts
    return {"summary":"EDA summary placeholder", "charts": [], "insights": []}
