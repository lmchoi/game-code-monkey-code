# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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

## Running the Game

Open project in Godot 4.5 and press F5. Main scene: [scenes/game_ui.tscn](scenes/game_ui.tscn)

### Installing GUT (test framework)

`addons/` is gitignored — install GUT via the script before running tests:

```bash
make install-gut
```

Then enable it in Godot: Project → Project Settings → Plugins → enable GUT.

Run tests headlessly: `make test`

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

Before implementing any feature:
1. Plan 3-6 small commits
2. Each commit should be immediately testable
3. Implement → Test → Commit → Next

**Signal-Driven Design:**
- GameManager holds all state with property setters that emit signals
- UI components connect to signals in `_ready()`
- Never update UI directly — always emit signals from GameManager
- Core loop logic lives in GameManager

---

## Critical Implementation Rules

### ⚠️ Balance Values Live in JSON, Not Code
If a number affects feel or balance, it belongs in a data file — not hardcoded in GDScript.

**In `data/balance.json` (single source of truth):**
- Detection chance, strike consequences
- Payday interval, salary amounts
- Hustle income per day
- Ship quality thresholds and vibe bands
- Bug formula constants
- Win/loss thresholds

**In code:** logic only — never magic numbers. This includes structural constants (e.g. progress scale). If a bare number appears in code, it needs a name — either a `const` in the owning autoload, or a `balance.json` entry. There is no third option.

Balance can be tuned without opening Godot or touching any `.gd` files.

**Design reference:** `docs/BALANCE.md` — when you change a value there, mirror it in `data/balance.json`.

### ⚠️ Bugs Only Affect WORK
Bugs slow down job task progress. They do not affect HUSTLE or SHIP IT speed. This is intentional — hustling feels free, shipping is always instant.

---

## Writing Style

All game text should be:
- **Dry, deadpan humor** — not silly or over-the-top
- **Specific tech references** — "blockchain todo app", not generic "do the thing"
- **Absurdist but grounded** — corporate demands are ridiculous but recognizable
- **Dark without being mean** — satirical, not cruel

### The "Ducks" Double Meaning

**IMPORTANT:** "Ducks" 🦆 = fucks to give (subtle wordplay, NEVER explicit)

- Always use "ducks" in text (never profanity)
- Always use 🦆 emoji in UI

---

## Notes to Claude

- Reference docs for Claude live in `docs/reference/`. Keep them concise.
- Design docs: `docs/GDD.md`, `docs/DECISIONS.md`, `docs/BALANCE.md`
- Build plan: `docs/plans/PLAN.md`

### Before Implementing a Feature — Check These First

1. **Data files** (`data/*.json`) — may already have fields/structure ready but unused
2. **GameManager** (`autoloads/game_manager.gd`) — check existing variables, signals, constants
3. **TaskManager** (`autoloads/task_manager.gd`) — check what's already parsed from JSON

### What to Ask vs What to Look Up

**Don't ask — just check the code:**
- "Does X exist?" → grep/read the files
- "How does Y work?" → read the implementation

**Do ask:**
- Design direction ("should outages be instant or delayed?")
- Balance tuning ("is 10x too harsh?")
- Architecture decisions ("centralised or distributed?")

### Decide Now vs Playtest Later

> **Decide now** if changing it requires touching code or architecture.
> **Playtest** if changing it only requires changing a number in a config file.

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
