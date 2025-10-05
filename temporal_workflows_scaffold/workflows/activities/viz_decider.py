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
