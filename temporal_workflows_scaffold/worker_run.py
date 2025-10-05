"""
Temporal worker runner - registers workflows and activities.
Run this in a container to start a worker that polls Temporal.
"""
import asyncio
from temporalio.client import Client
from temporalio.worker import Worker
import workflows.chat_to_slide_workflow as chat_workflow
import workflows.text_to_visual_workflow as text_workflow

async def run_worker():
    client = await Client.connect("temporal:7233")
    worker = Worker(
        client,
        task_queue="agentic-task-queue",
        workflows=[chat_workflow.ChatToSlideWorkflow, text_workflow.TextToVisualWorkflow],
        activities=[
            # Provide activity callables by importing them here if needed
        ],
    )
    await worker.run()

if __name__ == '__main__':
    asyncio.run(run_worker())
