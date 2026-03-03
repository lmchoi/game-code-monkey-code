GODOT ?= /Applications/Godot.app/Contents/MacOS/Godot

.PHONY: help check test lint install install-gut

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

install: install-gut ## Install dev dependencies (GUT + gdtoolkit)
	python3 -m venv .venv-lint
	.venv-lint/bin/pip install gdtoolkit==4.5.0

install-gut: ## Install GUT test framework into addons/
	bash scripts/install_gut.sh

lint: ## Lint GDScript with gdlint
	.venv-lint/bin/gdlint autoloads/ scenes/ test/

check: ## Check for Godot errors headlessly
	$(GODOT) --headless --quit 2>&1

test: ## Run GUT test suite headlessly
	$(GODOT) --headless -s addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json -gexit
