GODOT ?= /Applications/Godot.app/Contents/MacOS/Godot

.PHONY: help check test lint install install-gut install-hooks

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
	$(GODOT) --headless --quit 2>&1

test: ## Run GUT test suite headlessly
	$(GODOT) --headless -s addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json -gexit
