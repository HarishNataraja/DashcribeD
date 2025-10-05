from temporalio import activity

@activity.defn
async def ingest_source(source_descriptor: dict) -> dict:
    """
    Ingest data from a source.
    source_descriptor could include type: 'csv'|'excel'|'db', path or connection details.
    Returns a dict with keys: schema, sample_rows_path, fingerprint
    """
    # TODO: implement ingestion logic (parsers, connectors)
    return {"schema": {}, "sample_rows_path": "/tmp/sample.csv", "fingerprint": "sha1-..."}
