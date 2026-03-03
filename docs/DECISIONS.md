# Grind Mode — Open Design Decisions

Decisions being actively discussed or reconsidered. Once resolved, update the GDD and mark as closed here.

| Status | Tag | When | Decision |
|--------|-----|------|----------|
| 🟡 Open | `[DESIGN]` | Post-core-loop | [victory-endings](#open-victory-endings) |
| 🟡 Open | `[ARCHITECTURE]` | Post-core-loop | [task-categories](#open-task-categories) |
| 🟡 Open | `[ARCHITECTURE]` | Post-core-loop | [multi-task](#open-multi-task) |
| 🟡 Open | `[ARCHITECTURE]` | Post-core-loop | [productivity-meter](#open-productivity-meter) |
| 🟡 Open | `[ARCHITECTURE]` | Post-core-loop | [hustle-varied-tasks](#open-hustle-varied-tasks) |
| 🟡 Open | `[DESIGN]` | Playtest | [game-duration](#open-game-duration) |
| 🟡 Open | `[DESIGN]` | Playtest | [bug-feedback-on-ship](#open-bug-feedback-on-ship) |
| ✅ Closed | `[DESIGN]` | Pre-build | [work-on-complete-task](#closed-work-on-complete-task) |
| ✅ Closed | `[DESIGN]` | Pre-build | [ducks-v1](#closed-ducks-v1) |
| ✅ Closed | `[DESIGN]` | Pre-build | [promotion-mechanic](#closed-promotion-mechanic) |
| ✅ Closed | `[ARCHITECTURE]` | Pre-build | [post-ship-flow](#closed-post-ship-flow) |
| ✅ Closed | `[ARCHITECTURE]` | Pre-build | [day-sequence](#closed-day-sequence) |
| ✅ Closed | `[ARCHITECTURE]` | Pre-build | [task-complexity-deadline](#closed-task-complexity-deadline) |
| ✅ Closed | `[DESIGN]` | Pre-build | [ship-it-placement](#closed-ship-it-placement) |
| ✅ Closed | `[DESIGN]` | Pre-build | [complexity-visibility](#closed-complexity-visibility) |
| ✅ Closed | `[DESIGN]` | Pre-build | [ship-threshold-progression](#closed-ship-threshold-progression) |
| ✅ Closed | — | Pre-build | [hustle-escape-mechanic](#closed-hustle-escape-mechanic) |
| ✅ Closed | — | — | [progression-feeling](#closed-progression-feeling) |
| ✅ Closed | — | — | [three-actions](#closed-three-actions) |
| ✅ Closed | — | — | [no-forgiveness-principle](#closed-no-forgiveness-principle) |
| ✅ Closed | — | — | [game-duration](#closed-game-duration) |
| ✅ Closed | — | — | [tagline](#closed-tagline) |

---

## [DESIGN]

Decisions that affect what the player experiences. Decide before building.

---

### OPEN: game-duration

**Question:** What's the target playtime per run?

**Decision:** Short replayable game — 10-15 minutes per run, designed for 3-5 distinct runs before repetition sets in.

**Rationale:**
- The tension peaks mid-run (bugs mounting, deadline close, HUSTLE vs WORK dilemma) — short runs hit that peak and end before it gets repetitive
- Cheap failure encourages riskier strategies and "one more run" pull
- Dramatically easier to build and balance as a solo dev (15-20 tasks, 3-5 event types)
- Aligns with the vision — this is a short story, not a novel
- Replay value comes from distinct endings + randomised task draws, not length

**Still needs:** Balance values (day count targets, task count) confirmed against actual playtesting.

**Status:** Locked in principle, thresholds TBD after playtesting.

---

### OPEN: victory-endings

**Question:** How do the 7 flavoured victory endings work — what stats trigger them, priority order, and are they only reachable via victory?

**Current ideas (not locked):**

| Ending | Trigger idea |
|--------|-------------|
| THE PERFECTIONIST | Few bugs, escaped slowly |
| THE PRAGMATIST | Moderate bugs, consistent quality |
| THE BURNT-OUT HUSTLER | 0 ducks remaining at escape |
| THE SPEED RUNNER | Escaped fast |
| THE TECHNICAL DEBT MONSTER | Lots of bugs |
| THE AI PROMPT ENGINEER | Consistently low quality |
| THE SURVIVOR | Multiple production outages |

**Open questions:**
- Are these all victory-only, or can some be reached via loss?
- What happens when multiple triggers apply? Need priority order.
- SPEED RUNNER threshold needs calibrating against final run length
- THE SURVIVOR feels like a near-loss — is that intentional flavour?

**Status:** Ideas captured, not locking until core loop is validated via playtesting.

---


### OPEN: bug-feedback-on-ship

**Question:** What does the player see when they're about to SHIP IT — exact bug count, a range, a vibe indicator, or nothing?

**Options:**
- **Exact:** "Ship now? +3 bugs" — precise, but gameable (players min-max to exact thresholds)
- **Range:** "Ship now? +2-5 bugs" — honest about uncertainty, still lets player reason
- **Vibe:** 🟢 clean / 🟡 risky / 🔴 dangerous — emotional not calculated, fits the theme
- **Hidden:** just the progress bar — most dramatic, might feel unfair

**Lean:** Vibe only. You never really know how many bugs you're introducing. Keeps decisions emotional rather than calculated.

**Implementation note:** Must be configurable in balance.json — UI reads from config so this can be flipped without touching logic.

**Status:** Open. Don't lock until playtesting reveals which feels best.

---

## [ARCHITECTURE]

Decisions that require code or system design. Decide before building the affected feature.

---



### OPEN: task-categories

**Question:** Should tasks have categories (Optics / Tech Debt / Critical) with distinct mechanics?

**Parked ideas:**
- **Optics** — short deadlines, political risk (PIP warning if overdue 1 day)
- **Tech Debt** — bug multiplier 3× when shipped incomplete
- **Critical** — shipped below 80% guarantees production outage next day

**Approach:** Start with generic tasks. Add categories in a second pass if playtesting reveals tasks feel too same-y.

**Status:** Parked. Don't build until core loop is validated.

---

### OPEN: multi-task

**Question:** Can the player have more than one active task? e.g. a coworker asks for help — does that add a second task to manage, or just reduce productivity on the current one?

**Option A: Productivity hit** `[BALANCE]`
Coworker interruption = WORK progress reduced that day. Simpler, no extra UI needed. Just a number change.

**Option B: Second task on the plate** `[ARCHITECTURE]`
Adds a queue mechanic — player now juggles two deadlines. More stressful, more authentic to corporate life, but requires task queue UI and logic.

**Lean:** Productivity hit first. If playtesting reveals interruptions feel too weightless, escalate to second task.

**Status:** Parked. Don't decide until core single-task loop is validated.

---

### OPEN: productivity-meter

**Question:** Should there be a productivity multiplier that increases when the player focuses on a task across consecutive days, and decreases when interrupted? Progress would then be: `complexity × productivity × bug_penalty`.

**Option A: No productivity meter** `[BALANCE]`
Progress = `complexity × bug_penalty` only. Simpler, fewer variables for the player to track.

**Option B: Productivity meter** `[ARCHITECTURE]`
New resource/state to track. Rewards focus, punishes context-switching. Creates a hidden cost to HUSTLE — every HUSTLE day breaks your focus streak.

**Considerations:**
- Adds genuine depth: HUSTLE now costs momentum as well as detection risk
- Risk: fourth resource may be one too many for a 10-15 min game
- If added, must be visible to the player — hidden meters are frustrating

**Status:** Parked. Don't decide until core loop is built and playtested.

---

### OPEN: hustle-varied-tasks

**Question:** Should HUSTLE offer a different opportunity each day (varied reward, varied risk) or fixed reward every day?

**Current:** Fixed — HUSTLE always earns the same amount, same detection risk formula.

**Future idea:** Each day shows a different hustle opportunity (freelance gig, tweet about startup, cold email VCs) with different payouts and detection risk. Creates a real daily decision rather than a mechanical press.

**Approach:** Start fixed. Add variety in a second pass after core loop is validated via playtesting.

**Status:** Parked. Don't build until fixed HUSTLE is working and fun.

---

## Closed

---

### CLOSED: tagline
Dropped from GDD. Keep for marketing/pitch copy only (ONE-PAGER.md).

### CLOSED: game-duration
Locked: 10-15 min per run, 3-5 runs before repetition. Fast failure (2 min) for dumb strategies, full run for players threading the needle.

### CLOSED: no-forgiveness-principle
Kept. Managing consequences is more fun than avoiding mistakes. Validated by design discussion.

### CLOSED: three-actions
Kept. 3 is enough for a 15-min game. Context makes them feel different each day.

### CLOSED: progression-feeling
Resolved by hustle-escape-mechanic decision. Money bar is the progression. Recap screen is the payoff. Short run doesn't need traditional progression hooks.

### CLOSED: hustle-escape-mechanic
Money only. No escape % bar. Save enough to escape. WORK earns salary, HUSTLE earns side income — both count, HUSTLE is faster but riskier. One number, one goal, immediately legible.

### CLOSED: complexity-visibility
Complexity is visible but not as a number. Shown as spaghetti emoji on the task card (🍝 = simple, 🍝🍝🍝 = nightmare). Player reads the mismatch between spaghetti and deadline instantly — no tooltip needed. Complexity value stays in JSON, never surfaced directly.

### CLOSED: ship-threshold-progression
Fixed threshold (50% minimum), natural learning. Early tasks are simple enough that players hit 80%+ without trying. Mid-game complexity + tight deadlines force earlier ships — player discovers it under pressure, not from a tooltip.

### CLOSED: ship-it-placement
Task-level. SHIP IT lives on the task card, not as a global daily button. 2 daily actions (WORK / HUSTLE) + 1 task action (SHIP IT). Greys out until minimum progress threshold. Update pitch copy — drop "3-button game" framing.

### CLOSED: work-on-complete-task
When task hits 100%, WORK is disabled. SHIP IT on the task card is highlighted. No new button, no prompt — player's options are naturally HUSTLE or ship. `[JUICE]` — just a visual state change on the task card.

### CLOSED: ducks-v1
Parked. Ducks need moral choice triggers (outages, blame coworker) to feel meaningful — without them they're just a slow counter. V1 core loop is money + bugs only. Ducks are one afternoon to add: one integer, one drain check on ship, one loss condition. Add in second pass once moral choice moments exist.

### CLOSED: promotion-mechanic
Parked for V1. Golden handcuffs as a *concept* stays — pure WORK players get trapped by accumulating bugs and slow progress. Promotion as a *mechanic* (complete X tasks → manager → game over) is the dramatic version, added in a second pass. If playtesting reveals the trap isn't felt without promotion, add it then.

### CLOSED: post-ship-flow
Shipping ends the day. One action per day — if you ship, that's your day. New task appears, day advances. No WORK or HUSTLE on the same day. Easy to switch to "free ship" later — one boolean in the day loop.

### CLOSED: day-sequence

Each day resolves in this order:

1. **Constraint phase** — start of day, fires nothing in V1. Reserved for future events (workmate needs help, etc.). Must exist as an empty hook in the architecture.
2. **Player action** — pick WORK or HUSTLE, or SHIP IT via task card
3. **Consequence phase** — post-action. Detection roll if hustled, duck lost if shipped below threshold
4. **Bookkeeping** — payday (every N days), overdue check
5. **Win/loss check**
6. **Next day**

**Constraints vs consequences:**
- Constraints = things that happen *to* you (start of day) — limit your options
- Consequences = things that happen *because of* you (post-action) — punish your choices

Both phases exist in the architecture from day one. Only consequences fire in V1.

### CLOSED: task-complexity-deadline
Both. Complexity drives how fast WORK progresses. Deadline is independent. The mismatch between the two is the core tension — a complex task with a tight deadline forces bad ships; breathing room lets you hustle.

### OPEN: ship-vibe-indicator
SHIP IT button currently shows no quality signal — just enabled/disabled at 50%. The 🟢/🟡/🔴 vibe indicator is `[JUICE]`. Players can infer quality from bugs accumulating after a bad ship. Add after core loop is complete and playtested.

### OPEN: payday-feedback
Payday is currently silent — money just jumps in the top bar. No explicit signal to the player.
`[JUICE]` — a brief toast or flash ("PAYDAY 💸") would make the moment land. Doesn't affect balance, pure feel. Defer until after core loop is complete.
