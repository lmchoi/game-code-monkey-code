Review a pull request and write structured feedback to `.claude/last-review.md` for the working agent, then post inline comments to GitHub for human visibility.

Steps:

1. If no PR number is provided, run `gh pr list` and stop.

2. Run `gh pr view <number>` to get the PR title and description.

3. Run `gh pr diff <number>` to get the diff. Also run `gh api repos/{owner}/{repo}/pulls/<number>/files --jq '.[] | {filename, patch}'` to get per-file patches with line positions for inline comments.

4. Analyse the diff thoroughly. For each issue found, classify it:
   - **severity**: `error` (must fix before merge), `warning` (should fix), `nit` (minor/style)
   - **category**: `convention` (vs CLAUDE.md rules), `correctness` (logic/bugs), `test` (missing or fragile tests), `architecture` (design concerns)

   **Architecture checks to always apply:**
   - No game logic in UI/scene scripts (`scenes/*.gd`). Logic belongs in autoloads (`autoloads/*.gd`). UI reads state and calls autoload methods — it must not set `game_over_reason`, mutate `on_pip`, or make decisions that affect game state. Flag any such code as `error` + `architecture`.
   - Simulation script (`scripts/simulate.gd`) must not duplicate logic from autoloads — it should call the same methods the game uses. If `_on_review` or similar handlers re-implement logic instead of calling a `GameManager` method, flag it.

5. Write `.claude/last-review.md` with this exact structure:

```
# Review: PR #N — [title]

## Structured Comments
```json
[
  {
    "file": "path/to/file",
    "line": 42,
    "severity": "error|warning|nit",
    "category": "convention|correctness|test|architecture",
    "message": "One-line summary of the issue",
    "suggestion": "Optional concrete fix"
  }
]
```

## Summary
[2-3 sentence prose overview of the PR and overall verdict]

## Full Review
[The full prose review with sections: Overview, Correctness, Architecture, Tests, Summary]
```

6. Post the review to GitHub:
   - Get the head commit SHA from `gh pr view <number> --json headRefOid -q .headRefOid`
   - Post inline comments via `gh api repos/{owner}/{repo}/pulls/<number>/reviews` with the overall summary as `body`, `event` as `"COMMENT"`, and per-file inline `comments` using the correct diff positions from step 3
   - Only post inline comments for issues that map to a specific line in the diff

7. Report to the user: how many issues found by severity, and confirm `.claude/last-review.md` was written.
