Run the Godot project headlessly, capture all output, and report any errors.

Steps:
1. Run `godot --headless --quit 2>&1 | tee /tmp/code-monkey-check.log` from the project root
2. Read `/tmp/code-monkey-check.log`
3. Report clearly: either "✅ No errors" or list every error/warning with the relevant line
