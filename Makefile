.PHONY: setup deps run-live run-dry

deps:
	python3 -m venv .venv || python -m venv .venv
	. .venv/bin/activate; pip install --upgrade pip; pip install openai sqlparse python-dotenv

run-dry:
	. .venv/bin/activate; python -c "print('dry run placeholder')"
