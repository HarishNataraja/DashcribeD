from temporalio import workflow
import workflows.activities.nl_to_sql as nl_to_sql
import workflows.activities.sql_simulator as sql_simulator
import workflows.activities.eda as eda
import workflows.activities.outline as outline
import workflows.activities.slide_composer as slide_composer
import workflows.activities.export as export

@workflow.defn
class ChatToSlideWorkflow:
    @workflow.run
    async def run(self, query: str, schema: str, workspace_id: str) -> str:
        # 1. Generate SQL
        sql = await workflow.execute_activity(nl_to_sql.generate_sql, query, schema, start_to_close_timeout=30)
        # 2. Preview / simulate SQL
        preview = await workflow.execute_activity(sql_simulator.preview_query, sql, start_to_close_timeout=60)
        # 3. Run EDA
        eda_report = await workflow.execute_activity(eda.run_eda, preview, start_to_close_timeout=120)
        # 4. Draft outline
        outline_json = await workflow.execute_activity(outline.draft_outline, eda_report, start_to_close_timeout=60)
        # 5. Compose slides
        pptx_path = await workflow.execute_activity(slide_composer.compose, outline_json, start_to_close_timeout=120)
        # 6. Export and get signed URL
        signed_url = await workflow.execute_activity(export.upload_and_get_url, pptx_path, workspace_id, start_to_close_timeout=60)
        return signed_url
