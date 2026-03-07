# Playtesting Notes

Observations and design ideas from real play sessions and simulation runs.
Linked to run IDs in `logs/metrics.jsonl` where applicable.

---

## 2026-03-07 — Time pressure / game length cap

**Source:** simulation runs (all strategies) + real run `1772867092` (win, day 35)

Simulation findings: pure-work strategies (`diligent_worker`, `ship_asap`) win 100% of
runs at a deterministic day 51. There is no time pressure — a patient player cannot lose.
Meanwhile, `hustle_then_ship` wins at day 22 but only 35% of the time due to detection risk.

Real play confirmed: tension didn't arrive until late (around day 30+), at the point where
the player had to choose between shipping at 66% or hustling more. That decision felt like
the actual game — but it came too late.

Run `1772867092` breakdown: 17 work / 9 ship / 9 hustle over 35 days, 1 strike, won at $5300.
Over half the actions were pure work — the player was essentially in "safe mode" until forced
into a crunch decision near the end. Player note: "maybe the game needs to be longer" — meaning
more time *in* that tension zone, not more preamble before it.

**Ideas:**

- Hard game-over at day ~30: makes pure-work unviable (day 51 is out of reach), forces some
  hustling, raises stakes from the start.
- Soft variant: "performance review" at day 30 adds a strike if money < some threshold.
  Keeps the game alive but punishes slowness without a hard cutoff.
- Alternatively, extend the game intentionally so the crunch zone is longer rather than
  arriving later — more time in the tension window rather than more preamble before it.

---

## 2026-03-07 — Pacing levers (post run 1772867788)

**Source:** real run `1772867788` (win, day 25, 37s session — hustle-heavy, 0 bugs)

37 seconds is a full game. Way too short even accounting for fast clicking — the game has no
meaningful friction or ramp-up. First 1–2 minutes should feel like a warm-up; stakes should
build from there.

**Proposed levers (player feedback):**

- **Raise the win threshold** — $5,000 is too reachable too fast. A much higher number
  (e.g. $15,000–$20,000) would make the game arc longer and payday math more meaningful.
- **More tasks, harder tasks** — the task pool needs depth. Longer complexity curves mean
  more days spent in work/ship decisions before money accumulates.
- **Intentional warm-up phase** — the first few tasks should be low-stakes by design,
  letting the player learn the loop before detection risk and bug pressure compound.

---

## 2026-03-07 — Progression design

The game needs values that *change as you progress*, not just more of the same.
Currently almost everything is flat: salary, hustle pay, detection base rate, win threshold.
The only progression is reactive (bugs slow your work, strikes raise detection) — there's no
temporal progression, nothing that changes just because time has passed.

**Two types of progression to design for:**

- **Reactive** — changes driven by player choices (already partially exists: bug penalty, strike detection bonus)
- **Temporal** — changes driven by time passing regardless of what the player does (mostly missing)

**Proposed game phases:**

| Phase | Days (approx) | Feel |
|-------|---------------|------|
| Onboarding | 1–10 | Learn the loop. Easy tasks, low stakes, no real risk. |
| Grind | 10–25 | Stakes emerge. Tasks get harder, detection starts mattering. |
| Crunch | 25+ | Every decision counts. Tight deadlines, compounding pressure. |

**Temporal levers to introduce:**

- **Boss suspicion** — a slow-rising ambient pressure, not just triggered by detection events.
  Even clean play should feel the heat eventually.
- **Task difficulty ramp** — complexity and deadline windows tighten every N days, independent
  of player actions.
- **Performance reviews** — periodic checkpoints (e.g. every 15 days) where money below a
  threshold adds a strike. Forces the player to not just play it safe indefinitely.

**Reactive levers to strengthen:**

- **Reputation decay** — getting detected should have a lingering effect beyond the strike,
  making the boss permanently more watchful.
- **Sloppy ship memory** — bugs added from early ships compound into later task complexity,
  making early sloppiness visibly punish late-game speed.
