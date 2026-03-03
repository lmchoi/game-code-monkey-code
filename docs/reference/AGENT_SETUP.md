# Agent Setup

How the Claude Code automation is structured for this project.

---

## Mental Model

```
Skill (what to do)
    ↑
    ├── Slash command  → human triggers it
    ├── Hook           → lifecycle event triggers it automatically
    └── Agent tool     → another skill spawns it as a sub-agent
```

- **Skills** — define the steps (reusable, composable)
- **Slash commands** — human entry point into a skill
- **Hooks** — automated entry point into a skill, deterministic
- **Agent tool** — one skill spawning another as a sub-agent

Hooks exist because Claude is probabilistic — it *might* remember to run tests or review before committing. Hooks guarantee specific actions happen at defined lifecycle points regardless of what the LLM decides.

---

## Where Things Live

| Type | Location | Scope |
|---|---|---|
| Skills / slash commands | `.claude/commands/*.md` | Project (committed, shared) |
| | `~/.claude/commands/*.md` | User (all projects) |
| Hooks | `.claude/settings.json` | Project (committed, shared) |
| | `~/.claude/settings.json` | User (all projects) |
| Agent tool | Inline in prompts/skills | No file — used directly |

---

## What's in Place

### Skills (`.claude/commands/`)

| Command | What it does |
|---|---|
| `/check` | Runs Godot headlessly, reports errors |
| `/test` | Runs GUT suite, reports pass/fail |
| `/look` | Reviews current game screenshot |
| `/review <pr>` | Reviews a PR — writes `.claude/last-review.md` (structured JSON + prose) then posts inline comments to GitHub |

### Hooks

None yet. No `.claude/settings.json` exists.

Next candidate: a `Stop` hook (agent type) that runs `/review` automatically before the working agent finishes, blocking it if there are `error`-severity issues.

### Agent tool

Used ad-hoc in conversations. Not yet wired into any skill. `/review` could use it to fan out to specialist sub-agents in parallel.

---

## Review Workflow

**Current (Phase 1):**
```
working agent → pushes → creates PR
reviewing agent runs /review
    → writes .claude/last-review.md   (file channel — fast, no API roundtrip)
    → posts inline comments to GitHub  (human visibility)
working agent reads .claude/last-review.md to act on feedback
```

`.claude/last-review.md` is gitignored — ephemeral agent state.

**Planned (Phase 2):** Specialist skills (`/review-convention`, `/review-correctness`, `/review-tests`) that `/review` fans out to via the Agent tool.

**Planned (Phase 3):** `Stop` hook triggers review automatically — no human needed in the loop.

---

## Structured Review Format

`.claude/last-review.md` uses this schema for the working agent to consume:

```json
[
  {
    "file": "path/to/file",
    "line": 42,
    "severity": "error|warning|nit",
    "category": "convention|correctness|test|architecture",
    "message": "One-line summary",
    "suggestion": "Optional concrete fix"
  }
]
```
