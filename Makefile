GODOT ?= /Applications/Godot.app/Contents/MacOS/Godot

.PHONY: check test lint install-gut

install-gut:
	bash scripts/install_gut.sh

lint:
	gdlint autoloads/ scenes/ test/

check:
	$(GODOT) --headless --quit 2>&1

test:
	$(GODOT) --headless -s addons/gut/gut_cmdln.gd
