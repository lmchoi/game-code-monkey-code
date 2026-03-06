# AGENT.md

This file provides foundational guidance for AI agents (Claude Code, Gemini CLI, etc.) working on the **Code Monkey** project.

---

## Project Overview

**Code Monkey** — *"Office Space meets Universal Paperclips with duck-based resource allocation"*

A darkly comedic turn-based game built in Godot 4.5 where you're a tech worker trapped in corporate hell. Each day pick one action — WORK, HUSTLE, or SHIP IT. Escape with $5,000 before bugs make work impossible or your boss catches you hustling.

---

## Game Design Vision

**Design docs live in [docs/](docs/).**

### Core Concept
A darkly comedic game. Each day pick a daily action (WORK / HUSTLE) and decide whether to ship the current task (SHIP IT — on the task card). Escape with $5,000 before bugs make work impossible or you get caught hustling. 10-15 min per run, replayable via distinct endings.

### Core Loop
1. **Pick action** — WORK (safe), HUSTLE (risky), or SHIP IT (permanent)
2. **Consequences** — bugs added, money earned, detection roll if hustled
3. **End of day** — payday, overdue check
4. **Next day** — same situation, slightly worse

### Key Design Principles
1. **3 actions, all interconnected** — every action trades across bugs / money
2. **No forgiveness, only forward** — bugs never decrease, every choice compounds
3. **Bugs only affect WORK** — hustling feels free, but the job rots while you do it
4. **End-of-run recap** — Frostpunk-style, every choice surfaced, drives replay

---

## Running the Game & Workflows

Open project in Godot 4.5 and press F5. Main scene: [scenes/game_ui.tscn](scenes/game_ui.tscn)

### Custom Workflows
Always check `.claude/commands/` for specific project workflows and instructions (e.g., `test`, `look`, `check`, `review-pr`).

### Dev dependencies
`addons/` is gitignored. Run `make install` (GUT + gdtoolkit), then enable GUT in Godot: Project → Project Settings → Plugins → enable GUT. Run `make help` for all targets.

---

## Architecture & Workflow

### Font Size Hierarchy
Consistent font sizing for readability. Base defaults in [themes/main_theme.tres](themes/main_theme.tres). Scene files override as needed.

- **48px**: End game title (dramatic impact)
- **32px**: Top bar stats (always visible, critical info)
- **28px**: Task titles (primary headings)
- **24px**: Progress percentage, deadline (high visibility metrics)
- **22px**: Action buttons (important actions)
- **20px**: Base labels, metadata, badges (minimum readable size - theme default)

### Incremental Implementation
**IMPORTANT:** Break features into small, testable commits (20-100 lines, 1-3 files each).
1. Plan 3-6 small commits.
2. Each commit must leave the game in a runnable, non-broken state.
3. If a scene reference and the scene itself must arrive together, they go in the same commit — never split with a "crash expected" note.
4. Implement → Test → Commit → Next.

### TDD — Test First for Logic
**For any logic that qualifies for GUT** (pure functions, isolated game logic), write tests before implementation:
1. Write failing test.
2. Run `make test` — confirm failure.
3. Implement until green.
4. Commit both together.

This applies to every `calculate_*` function, every flag/state check, every signal-emitting condition. UI wiring and scene changes don't qualify — test those with `/check` and `/look` after the fact.

**Signal-Driven Design:**
- GameManager holds all state with property setters that emit signals.
- UI components connect to signals in `_ready()`.
- Never update UI directly — always emit signals from GameManager.
- Core loop logic lives in GameManager.

---

## Critical Implementation Rules

### ⚠️ Balance Values Live in JSON, Not Code
If a number affects feel or balance, it belongs in a data file — not hardcoded in GDScript.
- **In `data/balance.json`**: Detection chance, strike consequences, payday interval, salary amounts, hustle income, ship quality, bug formulas, win/loss thresholds.
- **In code**: logic only — never magic numbers. If a bare number appears in code, it needs a name (either a `const` or a `balance.json` entry).

**Design reference:** `docs/BALANCE.md` — when you change a value there, mirror it in `data/balance.json`.

### ⚠️ Bugs Only Affect WORK
Bugs slow down job task progress. They do not affect HUSTLE or SHIP IT speed.

---

## Writing Style
- **Dry, deadpan humor** — corporate demands are ridiculous but recognizable.
- **Specific tech references** — "blockchain todo app", not generic "do the thing".
- **The "Ducks" Double Meaning**: Always use "ducks" (🦆 emoji) instead of profanity.

---

## Notes for AI Agents

- **Reference docs**: `docs/reference/`.
- **Design docs**: `docs/GDD.md`, `docs/DECISIONS.md`, `docs/BALANCE.md`.
- **Check These First**:
    1. **Data files** (`data/*.json`) — may already have fields/structure ready.
    2. **GameManager** (`autoloads/game_manager.gd`) — check existing variables/signals.
    3. **TaskManager** (`autoloads/task_manager.gd`) — check what's already parsed.

### What to Ask vs What to Look Up
- **Don't ask — just check the code**: "Does X exist?", "How does Y work?".
- **Do ask**: Design direction, balance tuning, architecture decisions.

### Decide Now vs Playtest Later
- **Decide now** if changing it requires touching code or architecture.
- **Playtest** if changing it only requires changing a number in a config file.

If the answer is "just put it in balance.json and tune later", say so.

### Constraints vs Consequences

Two distinct event types — never mix them up:

- **Constraints** — things that happen *to* the player at the **start of day**. Limit options for that day.
- **Consequences** — things that happen *because of* the player's action, **post-action**. Punish choices.

Both phases exist in the day loop architecture. Only consequences fire in V1. Constraints are parked for later — do not retrofit them into post-action logic.

### Idea Tags

- `[ARCHITECTURE]` — requires code/system design decision now
- `[DESIGN]` — core mechanic or player experience decision, decide before building
- `[BALANCE]` — just a number, goes in balance.json, decide via playtesting
- `[JUICE]` — feel, animation, sound — build plain first, add later

### Project Memory (Claude Code)

Session memory is stored in `.claude/memory/MEMORY.md` in this repo. After cloning on a new machine, copy it to where Claude Code expects it:

```bash
mkdir -p ~/.claude/projects/-Users-<username>-workspace-game-code-monkey-code/memory/
cp .claude/memory/MEMORY.md ~/.claude/projects/-Users-<username>-workspace-game-code-monkey-code/memory/MEMORY.md
```

Adjust the path to match the absolute path of the project on your machine (`/` replaced with `-`).
