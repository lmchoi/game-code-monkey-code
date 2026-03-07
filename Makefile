-include config.mk

# Use GODOT4_BIN if defined, otherwise default to "godot"
GODOT4_BIN ?= godot

.PHONY: help check test test-py simulate lint install install-gut install-hooks

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

install: install-gut install-hooks ## Install dev dependencies (GUT + gdtoolkit + git hooks)
	python3 -m venv .venv-lint
	.venv-lint/bin/pip install gdtoolkit==4.5.0

install-gut: ## Install GUT test framework into addons/
	bash scripts/install_gut.sh

install-hooks: ## Install git hooks (pre-push lint)
	cp scripts/pre-push .git/hooks/pre-push
	chmod +x .git/hooks/pre-push

lint: ## Lint GDScript with gdlint
	.venv-lint/bin/gdlint autoloads/ scenes/ test/

check: ## Check for Godot errors headlessly
	$(GODOT4_BIN) --headless --quit 2>&1

test: test-py ## Run all tests
	$(GODOT4_BIN) --headless -s addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json -gexit

test-py: ## Run python unit tests
	python3 test/unit/test_analyze_log.py

simulate: ## Run strategy simulation and print outcome distributions
	$(GODOT4_BIN) --headless --script scripts/simulate.gd 2>/dev/null

STRATEGY ?= diligent_worker
trace: ## Trace a single game run with turn-by-turn logging (STRATEGY=name)
	$(GODOT4_BIN) --headless --script scripts/simulate.gd -- $(STRATEGY) 2>/dev/null
