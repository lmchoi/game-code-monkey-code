# Build Plan

---

## Main Screen

One screen for the entire game loop. Day advances automatically after consequences resolve — no "Next Day" button.

```
┌──────────────────────────────────────────┐
│  Day 1        💰 $0 / $5,000             │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│  Build a blockchain todo app             │
│  🍝🍝  ·  Due: Day 6                     │
│                                          │
│  ████░░░░░░░░░░░░░░░░  22%  (+8% flash) │
│                                          │
│  [ 🟢  SHIP IT ]                         │
└──────────────────────────────────────────┘

        [ WORK ]        [ HUSTLE ]
```

- Bugs hidden until non-zero, strikes hidden until triggered, goal always visible
- Title only — no description. Complexity as 🍝 emoji, never a number
- SHIP IT: vibe on button (🟢/🟡/🔴), greyed below 50%, WORK disabled at 100%
- Consequences surface inline. Quiet days auto-advance.

---

## Onboarding Curve (First 3 Tasks — Fixed)

Seeded from `data/tutorial_tasks.json` in order. No tutorial screen needed.

| Task | What player learns |
|------|--------------------|
| 1 | SHIP IT exists — pre-loaded ~85%, shows 🟢, safe to ship |
| 2 | Shipping costs something — ships 🟡, first bugs appear |
| 3 | Time pressure is real — HUSTLE once and overdue becomes possible |

Task 1 deadline: Day 6 (tune via balance.json after playtesting).

---

## Day Sequence

1. Constraint phase — fires nothing in V1, exists as empty hook
2. Player action — WORK, HUSTLE, or SHIP IT
3. Consequence phase — detection roll if hustled, bugs added if shipped
4. Bookkeeping — payday check, overdue check
5. Win/loss check
6. Day advances

---

## V1 Scope

**In:**
- WORK / HUSTLE / SHIP IT
- Money + bugs + day
- 3-strike detection system
- Payday every N days
- Tutorial tasks (fixed 3) + random pool
- Win: save $5,000
- Loss: bug spiral (100 bugs) or fired (3 strikes)
- Recap screen

**Parked:**
- Ducks
- Promotion / golden handcuffs
- Task categories (optics / tech debt / critical)
- Multi-task juggling
- Productivity meter
- Varied hustle tasks
- Interruptions / constraints
- Blame / outage mechanics

---

## Build Order

Each step = 1-3 commits. Game runs without errors after every commit.

| Step | What's built | How to test |
|------|-------------|-------------|
| 1 | Project skeleton — autoloads registered (empty), main scene | Game launches, no errors in console |
| 2 | Top bar (hardcoded) — Day 1, $0 / $5,000 renders | Visual: labels visible, font sizes correct |
| 3 | Top bar (wired) — GameManager signals drive labels | GUT: set `money = 500`, assert `money_changed` fires. Visual: label updates |
| 4 | Task card (hardcoded) — title, 🍝🍝, deadline, progress bar | Visual: card renders, progress bar at fixed % |
| 5 | Task card (from JSON) — first tutorial task populates card | GUT: TaskManager returns task with correct title/complexity. Visual: real task shows |
| 6 | WORK button — progress calculates, bar flashes, day advances | GUT: `do_work()` with 0 bugs vs 50 bugs gives correct progress delta. Visual: click WORK, bar updates |
| 7 | HUSTLE button — money increases, day advances | GUT: `do_hustle()` adds correct amount from balance.json. Visual: click HUSTLE, money updates |
| 8 | SHIP IT button — vibe indicator, greyed below 50%, ships task | GUT: ship at 80% → 🟢, 65% → 🟡, 52% → 🔴, 49% → blocked. Visual: new task loads |
| 9 | Consequences — bugs on ship, detection roll, strikes appear | GUT: ship at 60% adds correct bugs. GUT: mock `randf()` to force detection hit, assert strike increments. Visual: strike badge appears |
| 10 | Win/loss checks — money goal, bug spiral | GUT: money ≥ 5000 emits `victory`. GUT: bugs ≥ 100 emits `game_over`. Visual: game ends correctly |
| 11 | Recap screen — end of run summary | GUT: `get_game_stats()` returns correct dict. Visual: recap shows right numbers |

**Rule:** steps 1-4 are visual only. Steps 5+ get a GUT unit test before the visual check.
