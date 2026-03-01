# The Daily Grind — Game Design Document

**Mode:** grind (V1)
**Target:** 10-15 min per run, 3-5 runs before repetition

---

## Vision

A darkly comedic game. You're a tech worker trapped in corporate hell, secretly building a startup on company time. Every shortcut creates future pain. Escape before the job swallows you whole.

---

## Core Design Principles

### 1. No Forgiveness, Only Forward
Every choice compounds. No undo, no cleanup, no recovery.

- Bugs NEVER decrease (technical debt is forever)
- Shipped work can't be unshipped (bugs compound)
- Difficulty accelerates — you're always racing the spiral

### 2. Three Actions, All Interconnected
WORK / HUSTLE / SHIP IT. Every action trades across all three currencies.

- **Bugs** — your past catching up with you (only affects WORK)
- **Money** — your way out (HUSTLE earns it faster, WORK earns it safely)

3 actions is enough. The context makes them feel different every day.

### 3. The Only Winning Move
Ship *just good enough*. Hustle *just enough*. Escape before either trap closes.

- Ship bad work → bugs creep higher (death spiral)
- Only HUSTLE → caught and fired before you escape
- Only WORK → bugs slow you down, salary never enough to escape (golden handcuffs)

The game lives in the middle. That's the skill.

### 4. Fail Fast, Fail Legibly
Dumb strategies end in 2 minutes. The game teaches itself through fast failure.

- Spam WORK → bugs slow you to a crawl, never earn enough to escape
- Spam HUSTLE → caught and fired before you escape
- Spam SHIP IT → bug spiral, work grinds to halt

By run 3-4 the player understands the loop without a tutorial screen.

### 5. Endings Are Difficulty Tiers
Players self-select their challenge via endings. No explicit difficulty modes needed.

- Run 1-2: just try to escape
- Run 3+: chase a specific ending
- THE PERFECTIONIST is the hard mode. THE SPEED RUNNER is the speedrun. The game sets its own challenge.

---

## Core Loop

**Goal:** Save enough money to escape before bugs make work impossible.

**Each day, pick one action:**
- **WORK** — Make progress on the current corporate task
- **HUSTLE** — Earn side income toward escape (risky)

**On the task card:**
- **SHIP IT** — Complete task at current quality, add bugs, get new task. Ends the day.

**Core Tension:** "Can I earn enough to escape before they fire me for neglecting corporate work?"

---

## Resources

| Resource | Start | Game Over |
|----------|-------|-----------|
| Money | $0 | — |
| Bugs | 0 | 100+ = death spiral |
| Day | 1 | — |

---

## Three Actions

**WORK**
- Progress on task, scaled by complexity + bugs
- Complexity shown on task card as 🍝 (1-3 bowls) — never as a number
- Paid on payday (every 5 days)

**HUSTLE**
- Earn side income toward escape
- Risk detection if overdue

**SHIP IT**
- Complete task at current quality
- Adds bugs based on how incomplete it is — the worse the quality, the more bugs
- Triggers new task assignment

---

## Win Conditions

Save enough to escape.

WORK earns salary (payday every few days). HUSTLE earns side income (risky). Both count. HUSTLE is faster but gets you caught — WORK is safe but risks golden handcuffs.

---

## Loss Conditions

- **Death Spiral** — bugs pile up until work becomes impossible
- **Fired (deadline)** — task overdue too long and already on PIP

---

## Progression

**Week 1-2:** Simple tasks, long deadlines, learning the loop
**Week 3-4:** Medium complexity, bugs mounting, temptation grows
**Week 5-6:** High complexity, tight deadlines, must ship early to survive
**Week 7+:** Desperation mode, racing to escape

---

## Caught Hustling

Every time you choose HUSTLE, there's a chance your boss notices. Detection chance increases if your task is overdue, decreases if you've been shipping quality work. See BALANCE.md for exact values.

### 3-Strike System

**Strike 1 — Warning**
Boss pulls you aside. Detection chance increases for the next few days. No other penalty — but they're watching.

**Strike 2 — PIP**
Performance Improvement Plan. Detection chance increases. Must ship the next few tasks at decent quality or instant fired. PIP counter visible on screen.

**Strike 3 — Fired**
"Security will escort you out." Game over: *Caught Red-Handed* ending.

### The Core Question
You're not asking *if* you'll get caught. You're asking *can you finish before Strike 3?*

---

## Victory Endings

> ⚠️ See DECISIONS.md — victory-endings (triggers not locked)

Based on player stats:

| Ending | Trigger | Quote |
|--------|---------|-------|
| THE PERFECTIONIST | Few bugs, took your time | "You escaped with your soul intact." |
| THE PRAGMATIST | Moderate bugs, consistent quality | "You made the deals you had to make." |
| THE SPEED RUNNER | Escaped fast | "You got out before they could break you." |
| THE TECHNICAL DEBT MONSTER | Lots of bugs | "You left a trail of destruction." |
| THE AI PROMPT ENGINEER | Consistently low quality | "You shipped TODO comments as features." |

---

## Recap Screen

Shown at end of every run (win or loss). Frostpunk-style — every choice surfaced in hindsight.

```
Day 18 — You escaped.
You shipped 6 tasks. 3 under 60%.
31 bugs followed you out the door.

THE TECHNICAL DEBT MONSTER
"You left a trail of destruction."
```

Players read it, cringe, and immediately want to do better. This is the replay hook.

---

## Writing Style

- **Dry, deadpan humor** — not silly or over-the-top
- **Specific tech references** — "blockchain todo app", not "do the thing"
- **Absurdist but grounded** — corporate demands are ridiculous but recognizable
- **Dark without being mean** — satirical, not cruel

---

*Balance values: [BALANCE.md](BALANCE.md)*
