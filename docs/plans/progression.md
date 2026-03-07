# Progression & Game Length

**Status:** 💡 Idea

Design direction for giving the game a meaningful arc — warm-up, build, crunch —
rather than a flat loop that ends when the money target is reached.

---

## Problem

Almost everything is flat: salary, hustle pay, detection base rate, win threshold.
The only progression is reactive (bugs slow work, strikes raise detection risk).
There's no temporal progression — nothing changes just because time has passed.

Real play: a 37-second win via hustle spam. A patient or fast player can't lose.
The tension window exists but arrives too late and ends too quickly.

---

## Target game length

~10 minutes. At current pace (~1.5s/action, 1 action/day) that's ~300–400 days.
Win threshold needs to rise significantly from $5,000 to support this arc.

Rough income estimate with mixed play (~1/3 hustle): ~$165/day.
At 300 days that's ~$50,000 — working target for the win threshold.

Interesting coincidence: at day 30 with mixed play, a player has ~$5,000 — exactly
the current win threshold. Day 30 is where the current game ends.

---

## Game phases

| Phase | Days (approx) | Feel |
|-------|---------------|------|
| Warm-up | 1–30 | Learn the loop. Low stakes. Boss is watching but not pressing. |
| Grind | 30–200 | Stakes emerge. Tasks harder, detection matters, money compounds slowly. |
| Crunch | 200+ | Every decision counts. Tight deadlines, compounding pressure. |

---

## Day 30 review

A narrative event that marks the end of the warm-up. The player's behaviour in days
1–30 determines the outcome — unlocking a different path for the rest of the game.

**Path examples (based on playstyle):**
- Shipped clean, low bugs → **promoted**: higher salary, harder tasks, more scrutiny
- Hustled without getting caught → **trusted**: more hustle pay, but detection consequences worse
- Got caught / too many bugs → **on thin ice**: stricter deadlines, less tolerance

**Report card — what the boss grades (visible work only):**

| Grade | Measures |
|-------|----------|
| Quality | Ship completion % at time of ship, bugs added across all ships |
| Output | Tasks completed, weighted by complexity |
| Timeliness | Tasks delivered on time vs overdue, overdue days accumulated |

Hustle is not a graded category — the boss grades what they *know*. Strikes and detection
events colour their perception but don't appear explicitly on the card.

Grades combine to determine the path unlock. High quality + high output + on time = promotion.
Each grade could independently unlock something rather than funnelling into one of three archetypes
— more mix-and-match, more replayability.

**Presentation:** dialogue/narrative, not a stats screen. Boss calls you in (Slack message,
meeting invite, whatever fits the tone). The vibe is clear; exact mechanical changes
reveal themselves through play.

Examples:
- Clean shipper: "We've been impressed with your output. We'd like to offer you a new role..."
- Hustler: "You've been busy. We're not sure what with, exactly. Let's call it... initiative."
- Struggling: "We need to talk about your performance over the last month."

**Open question:** does the player know the real win target ($50k) from the start, or does
the review reframe the scope as a surprise? Surprise has higher narrative impact but risks
feeling unfair if not telegraphed at all.


---

## Levers

**Temporal (missing, need adding):**
- Task difficulty ramp — complexity and deadline windows tighten every N days
- Boss suspicion — slow ambient rise, not just triggered by detection events
- Performance reviews — money checkpoint every ~30 days, strike if below threshold

**Reactive (partially exists, strengthen):**
- Reputation decay — detection should have a lingering watchfulness effect beyond the strike
- Sloppy ship memory — bugs from early ships compound into later task difficulty
