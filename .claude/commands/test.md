Run the GUT test suite headlessly and report results.

Steps:
1. Run `godot --headless -s addons/gut/gut_cmdln.gd 2>&1 | tee /tmp/code-monkey-test.log` from the project root
2. Read `/tmp/code-monkey-test.log`
3. Report clearly: how many tests passed/failed, and list any failures with the relevant assertion
