# Progression Unlocks — Feature Plan

**Status:** 💡 Idea

The player doesn't get better at their job — they get better at getting away with it. Cynical skill progression.

Unlocks happen automatically at review milestones (day 30, day 60). No new decision points for now.

---

## Unlocks

### Day 30 — Lower Quality Threshold

`ship_vibe_green` drops from 80 to a lower value (e.g. 70).

The player can now ship tasks at lower completion without it counting as sloppy. They've learned what "good enough" looks like here.

**Open questions:**
- What value does it drop to? (needs playtesting)
- Does it drop again at day 60?

---

### Day 30 — Free Deadline Passes

`free_deadline_passes` is set to N (e.g. 3).

When a deadline is missed and passes remain, the miss is silent — no warning, `tasks_late` not incremented, pass consumed. They've faded into the background; one late ticket doesn't raise eyebrows anymore.

**Open questions:**
- How many passes? (needs playtesting)
- Do unused passes carry over after the day 30→60 period, or reset?
- Does the day 60 review grant more passes?

---

## Open Questions (System-Level)

- Should unlocks be automatic or tied to review grade outcomes?
  (Automatic is simpler; grade-gated is more interesting but adds complexity)
- Are there day 60 unlocks, or does the system top out at day 30?
- Does anything unlock mid-period (e.g. via a specific task)?

---

## Dependencies

- `ship_vibe_green` already lives in `balance.json` — needs to become a `GameManager` var to be mutable
- `free_deadline_passes` is a new `GameManager` var
- Review dialog (day 30) is where unlocks are applied — not yet built (plan step 7)
