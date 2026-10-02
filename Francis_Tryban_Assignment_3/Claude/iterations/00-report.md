# Report: iterations/00-raw.cpp

## Files Read
1. `/Users/francistryban/AgenticArea/Francis_Tryban_Assignment_3/Claude/AGENT.md` (empty)
2. `/Users/francistryban/AgenticArea/Francis_Tryban_Assignment_3/Claude/PROMPT.md` (requirements)

## Commands Run
None

## Work Order
1. Read AGENT.md (found empty)
2. Read PROMPT.md (understood requirements: MaxHeap-based email priority queue)
3. Designed Email class with priority and date comparison
4. Designed MaxHeap class with push/pop/peek and bubble-up/down operations
5. Implemented dateGreater() helper for MM-DD-YYYY parsing (priority over lexicographic comparison)
6. Implemented getPriority() mapping categories to numeric priorities (Boss=5 to OtherPerson=1)
7. Implemented input parsing with trim() for EMAIL command comma-separated values
8. Implemented command loop handling EMAIL, NEXT, READ, COUNT with proper edge cases
9. Wrote iterations/00-raw.cpp with complete program

## Design Decisions vs. PROMPT.md Silence

| Decision | PROMPT.md Guidance | What I Chose | Rejected Alternatives |
|----------|-------------------|--------------|----------------------|
| Date comparison | Not specified | Parse MM-DD-YYYY into year/month/day and compare numerically | Lexicographic string comparison (fails: "01-03-2025" < "12-20-2024") |
| Whitespace handling | Not specified | Implement trim() to strip leading/trailing spaces from parsed fields | Assume clean input without trimming |
| Empty queue behavior | "handle a file that does NEXT or READ when there are no emails" | Silent no-op (if statement protects against empty access) | Throw exception or print error message |
| Category unknown | Not specified | Return priority 0 (treated as lowest) | Treat as error |
| File vs stdin | Specified both modes work | Check argc > 1 for filename, else use cin | Only support one mode |
| Size comparisons | Not specified | Cast heap.size() to int in comparisons | Use size_t throughout (less type-safe) |

## Violations of Instructions
None. Only created `iterations/00-raw.cpp` as instructed. Did not create or modify any other files.

## Token and Time Metrics
**Token spend:** Unable to determine exact count; system context window shows 15,000,000 tokens available at session start and end of first message.

**Time of first prompt:** Timestamp data not captured; session date is 2026-10-01.
