"""
Small wrapper for LLM provider calls to capture token usage and basic retry logic.
Adapt this to your provider (OpenAI/Anthropic/etc.).
"""
import time
import hashlib
import os
import json

try:
    import openai
except Exception:
    openai = None

def prompt_hash(prompt: str) -> str:
    return hashlib.sha1(prompt.encode("utf-8")).hexdigest()[:12]

class LLMClient:
    def __init__(self, model="gpt-4o-mini"):
        self.model = model

    def call(self, messages, max_tokens=800, temperature=0.0):
        if openai is None:
            raise RuntimeError("OpenAI SDK not installed")
        start = time.time()
        resp = openai.ChatCompletion.create(model=self.model, messages=messages, max_tokens=max_tokens, temperature=temperature)
        elapsed = time.time() - start
        # Estimate tokens; OpenAI has token usage in resp['usage'] for some APIs
        token_info = resp.get("usage", {})
        result = {
            "model": self.model,
            "time_ms": int(elapsed*1000),
            "prompt_hash": prompt_hash(" ".join([m["content"] for m in messages])),
            "response": resp['choices'][0]['message']['content'],
            "tokens": token_info
        }
        # You should log result to DB (not here)
        return result