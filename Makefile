.PHONY: install format format-check lint typecheck test coverage quality

install:
	uv sync --all-groups

format:
	uv run ruff format .

format-check:
	uv run ruff format --check .

lint:
	uv run ruff check .

typecheck:
	uv run mypy src tests

test:
	uv run pytest -q

coverage:
	uv run pytest --cov=rag_production --cov-report=term-missing

quality: format-check lint typecheck test
