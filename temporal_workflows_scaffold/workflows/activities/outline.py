from temporalio import activity

@activity.defn
async def draft_outline(eda_report: dict) -> dict:
    """
    Produce a slide-level outline (MECE-like) from EDA insights.
    """
    # TODO: call presentation outline agent / LLM
    return {"slides":[{"index":0,"title":"Executive Summary","bullets":["Key insight 1","Key insight 2"], "chart_ids": []}], "notes": {}}
