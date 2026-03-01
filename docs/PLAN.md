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
| 1 | Project skeleton — autoloads registered (empty), main scene | `/check` — no errors |
| 2 | Top bar (hardcoded) — Day 1, $0 / $5,000 renders | `/check` + run game, eyeball it |
| 3 | Top bar (wired) — GameManager signals drive labels | `/check` + run game, verify labels update |
| 4 | Task card (hardcoded) — title, 🍝🍝, deadline, progress bar | `/check` + run game, eyeball it |
| 5 | Task card (from JSON) — first tutorial task populates card | `/check` + run game, verify real task shows |
| 6 | WORK button — progress calculates, bar flashes, day advances | `/check` + click WORK, verify bar updates and day ticks |
| 7 | HUSTLE button — money increases, day advances | `/check` + click HUSTLE, verify money updates |
| 8 | SHIP IT button — vibe indicator, greyed below 50%, ships task | `/check` + click SHIP IT, verify new task loads |
| 9 | Consequences — bugs on ship, detection roll, strikes appear | `/check` + play until consequence fires, verify it shows |
| 10 | Win/loss checks — money goal, bug spiral | `/check` + cheat money/bugs to threshold, verify game ends |
| 11 | Recap screen — end of run summary | `/check` + finish a run, verify recap shows correct numbers |

**Rule:** `/check` before every commit. `/look` any time you want a second opinion on layout.
