from temporalio import workflow
import workflows.activities.text_parse as text_parse
import workflows.activities.viz_decider as viz_decider
import workflows.activities.component_gen as component_gen
import workflows.activities.export as export

@workflow.defn
class TextToVisualWorkflow:
    @workflow.run
    async def run(self, text: str, workspace_id: str) -> str:
        parsed = await workflow.execute_activity(text_parse.parse, text, start_to_close_timeout=60)
        viz_type = await workflow.execute_activity(viz_decider.choose_type, parsed, start_to_close_timeout=30)
        canvas_spec = await workflow.execute_activity(component_gen.build, parsed, viz_type, start_to_close_timeout=90)
        signed_url = await workflow.execute_activity(export.upload_and_get_url, canvas_spec, workspace_id, start_to_close_timeout=60)
        return signed_url
