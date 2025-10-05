from temporalio import activity

@activity.defn
async def upload_and_get_url(artifact, workspace_id: str) -> str:
    """
    Upload artifact (pptx/svg/json) to object storage and return a signed URL.
    """
    # TODO: integrate with S3/GCS and return pre-signed URL
    return "https://example.com/download/artifact.pptx?signature=stub"
