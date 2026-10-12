# PROGRESS

> A cold agent reads **only the NEXT ACTION block** to start working.
> Everything below it is reference, read on demand.

---

## ▶ NEXT ACTION

**Step:** S1 (`PLAN.md`)
**Do:** <the literal next action, specific enough to start typing>
**Files:** `path/to/file.ts:88-140`
**Verify:** `npm test -- auth`
**Blocked by:** none
**Watch out for:** <the one thing that will bite you here>

<!-- Rewrite this block after EVERY completed step and before EVERY session end.
     If it is stale, the next session pays full price to rediscover the state. -->

---

## ⛔ Dead ends — do not retry

| Tried | Why it failed | Instead |
|---|---|---|
| <approach> | <actual reason, not a guess> | <what worked / what to try> |

<!-- The highest-value section in this file. Every entry here is a session that
     the next agent doesn't have to spend. Add to it the moment something fails. -->

---

## 🧠 Decisions

| Date | Decision | Why | Reversible? |
|---|---|---|---|
| | | | |

<!-- Only decisions a future agent could plausibly undo by accident. -->

---

## 📓 Log — append-only, newest at the bottom

### `<date>` — S1 done
- Changed: `src/auth/token.ts:12-48` — extracted `verifyToken`
- Verified: `npm test -- auth` → 14 passed
- Note: <anything surprising>

<!-- One entry per completed step. Two to five lines. This is a ledger, not a diary:
     file:line anchors and exact commands, no narration of what you were thinking. -->
