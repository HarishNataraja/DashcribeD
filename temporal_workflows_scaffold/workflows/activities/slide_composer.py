from temporalio import activity

@activity.defn
async def compose(outline_json: dict) -> str:
    """
    Create PPTX from outline and return local path to PPTX file.
    """
    # TODO: render charts, embed images, create PPTX with python-pptx
    out_path = "/tmp/generated_presentation.pptx"
    # create placeholder file
    with open(out_path, "wb") as f:
        f.write(b"PK\\x03\\x04")  # minimal ZIP/PPTX header stub (not a valid PPTX)
    return out_path
