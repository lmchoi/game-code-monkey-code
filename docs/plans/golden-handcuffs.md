# Golden Handcuffs — Feature Plan

**Status:** 💡 Idea

A designed trap for players who work hard and never hustle. They get promoted at the day 30
review (good grades → salary rise, harder tasks, more scrutiny), feel safe, and realise too
late that they'll never earn enough to escape.

---

## Dependency

Requires review grades + mechanical consequences (`review-grades.md` Phase 2) to exist first.
Promotion is a consequence of high grades — it must feel earned, not arbitrary.

---

## The Trap

At day 30 review, a player with Good output + Good timeliness + Good quality gets promoted:

- **Salary rises** (e.g. +$200/payday) — feels like a reward
- **Tasks become harder** (tier2 or tier3 unlocked faster, or complexity weights increase)
- **Scrutiny increases** (detection base rate rises — hustle is now riskier)
- **Win goal is not revealed to be out of reach** — player discovers this through play

A pure WORK player accumulates salary but never enough. They can't pivot to hustle because
detection risk is now higher post-promotion. The only escape is to have started hustling early.

---

## Ending

`"THE GOLDEN HANDCUFFS"` — a win-condition that never comes. Player reaches day cap without
hitting win goal. Recap shows: stable job, respected, trapped.

Distinct from `fired_*` endings — this is a soft loss. The player wasn't bad enough to be
fired, just not ambitious enough to escape.

---

## Implementation Notes

- Add `promoted: bool` flag to `GameManager`, set at review if grades qualify
- Promotion triggers: salary modifier, detection modifier (via review grades system)
- New game-over reason: `"golden_handcuffs"` — emitted when day cap reached without win
- Day cap: TBD (existing game has no hard day limit — need to add one, e.g. day 90 or 120)
- Recap scene reads `"golden_handcuffs"` reason and shows the appropriate ending

---

## Open Questions

- What is the day cap? Currently the game has no hard end beyond win/fired.
- Does the player know the day cap exists, or does it arrive as a surprise?
- Should the promotion be telegraphed ("Congratulations, you've been promoted!") or subtle?

---

## Suggested Commit Order

1. Day cap in `game_manager.gd` + `balance.json` — `day_cap: 90`
2. `promoted` flag set at review based on grade thresholds
3. `golden_handcuffs` game-over reason emitted at day cap if not won
4. Recap scene: golden handcuffs ending text
