GODOT ?= /Applications/Godot.app/Contents/MacOS/Godot

.PHONY: check test

check:
	$(GODOT) --headless --quit 2>&1

test:
	$(GODOT) --headless -s addons/gut/gut_cmdln.gd
