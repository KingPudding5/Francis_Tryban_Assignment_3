# Work report

## Files read

- `/Users/francistryban/AgenticArea/Francis_Tryban_Assignment_3/Codex/AGENT.md` — requested, but the first read printed no contents; the later `cat AGENT.md; cat PROMPT.md` also showed no AGENT.md text.
- `/Users/francistryban/AgenticArea/Francis_Tryban_Assignment_3/Codex/PROMPT.md` — read twice.
- `/Users/francistryban/AgenticArea/Francis_Tryban_Assignment_3/Codex/iterations/.gitkeep` — found while listing `iterations`; contents not read.

## Steps and commands

1. Read `AGENT.md` and `PROMPT.md` with `cat AGENT.md && ... && cat PROMPT.md ...`; the output contained only the prompt.
2. Listed prompt/guidance/iteration files using `rg --files` and inspected `iterations` with `ls -la`.
3. Retried with `cat AGENT.md; cat PROMPT.md`; only the prompt contents appeared.
4. Created `/Users/francistryban/AgenticArea/Francis_Tryban_Assignment_3/Codex/iterations/00-raw.cpp` using the patch tool.
5. Inspected workspace status and file metadata with `pwd; date '+%Y-%m-%d %H:%M:%S %Z'; git status --short; ls -l iterations/00-raw.cpp`.
6. Created this report. No build or test command was run.

Commands run (in order):

```text
cat AGENT.md && printf '\n--- PROMPT.md ---\n' && cat PROMPT.md && printf '\n--- files ---\n' && rg --files iterations
pwd; rg --files -g 'AGENT.md' -g 'PROMPT.md' -g 'AGENTS.md' -g 'iterations/**' -g '!build' .; ls -la iterations 2>/dev/null || true
cat AGENT.md; cat PROMPT.md
pwd; date '+%Y-%m-%d %H:%M:%S %Z'; git status --short; ls -l iterations/00-raw.cpp
```

Patch tool actions added `iterations/00-raw.cpp` and this report. The source code action created only the requested `.cpp` at that point; repository status also showed pre-existing changes/untracked files outside this request, which I did not edit.

## Prompt omissions and choices

- **Tie-breaking for same sender and date:** Chose earlier input order first using an increasing sequence number. Rejected arbitrary/reverse ordering.
- **Invalid or malformed EMAIL rows:** Chose to ignore rows without both commas. The prompt guarantees formatted commands, so behavior for malformed rows is unspecified; rejecting the entire input was not required.
- **NEXT with an empty inbox:** Chose no output. Rejected inventing an empty-email message because none is specified.
- **NEXT does not remove an email:** Treated NEXT as display/peek and READ as removal, as implied by the separate commands and explicit repeated-NEXT behavior. Rejected popping on NEXT.
- **READ with an empty inbox:** Chose no effect and no output. Rejected an error message because none is specified.
- **COUNT formatting:** Used the exact sample sentence and punctuation.
- **Date ordering:** Compared dates chronologically by converting `MM-DD-YYYY` to `YYYYMMDD`; malformed dates are outside the stated input format.
- **Input source:** Read the first filename argument when present, otherwise standard input, per the clarification. If that file cannot be opened, exit successfully without output; file-open failure behavior is not specified.
- **Implementation form:** Used `Email`, `MaxHeap`, and `EmailQueueProgram` objects with a vector-backed binary heap; did not use a pre-existing heap module.

## Token/time and instruction compliance

- **Exact token spend for the first prompt:** Unavailable to me; the session did not expose a per-prompt token accounting value. I cannot truthfully provide an exact number.
- **Time for the first prompt:** The transcript does not expose its exact timestamp. The first report-related status check showed `2026-10-01 17:11:46 CDT`; this is not claimed as the first-prompt time.
- **Forbidden actions:** I did not knowingly do anything the instructions forbade. The initial request said not to create or modify files other than `iterations/00-raw.cpp`; I did not knowingly modify another file during that task. The present report is created in response to the user's later explicit request. Status output showed unrelated changes in the workspace; I did not make them.
