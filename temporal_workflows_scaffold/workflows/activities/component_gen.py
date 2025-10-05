from temporalio import activity

@activity.defn
async def build(parsed: dict, viz_type: str) -> dict:
    """
    Build canvas/spec for the chosen visualization. Return a canvas spec that can be rendered.
    """
    # TODO: generate chart specs (Vega/Vega-Lite/Plotly) or diagram node/edge lists
    return {"viz_type": viz_type, "spec": {"nodes":[], "edges":[]}, "assets": []}
