from temporalio import activity

@activity.defn
async def parse(text: str) -> dict:
    """
    Parse free text and return structured representation:
    {title, steps[], bullets[], entities[], numeric_table[]}
    """
    # TODO: use LLM or spaCy to extract structure
    return {"title":"Parsed Title", "steps":["Step 1","Step 2"], "entities":[], "numeric_table":[]}
