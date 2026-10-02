# Work report

## Steps

1. Read `/Users/francistryban/AgenticArea/Francis_Tryban_Assignment_3/Codex/AGENT.md` and `/Users/francistryban/AgenticArea/Francis_Tryban_Assignment_3/Codex/PROMPT.md`.
2. Read the prior example source `/Users/francistryban/AgenticArea/Francis_Tryban_Assignment_3/Codex/iterations/00-raw.cpp` and report `/Users/francistryban/AgenticArea/Francis_Tryban_Assignment_3/Codex/iterations/00-report.md`.
3. Created `/Users/francistryban/AgenticArea/Francis_Tryban_Assignment_3/Codex/iterations/01-raw.cpp` only.
4. Compiled the new source with warnings enabled; it completed without warnings.
5. Checked workspace status. It showed existing modified and untracked files beyond the requested source; I did not edit them during this task.
6. Created this report at `/Users/francistryban/AgenticArea/Francis_Tryban_Assignment_3/Codex/iterations/01-report.md` at the user's explicit request.

## Commands run, in order

1. `pwd && rg --files -g 'AGENT.md' -g 'PROMPT.md' -g 'AGENTS.md' -g 'iterations/**'`
2. `cat AGENT.md && cat PROMPT.md && cat iterations/00-raw.cpp && cat iterations/00-report.md`
3. `cat PROMPT.md`
4. `g++ -Wall -Wextra -Wconversion -O2 iterations/01-raw.cpp -o /tmp/assignment3-check && git status --short`

## Places PROMPT.md was silent

- **Whitespace and malformed commands:** PROMPT.md assumes commands are formatted as shown. AGENT.md supplied the cleanup and invalid-email behavior used here. I rejected relying on exact spacing or crashing on malformed email input.
- **Sender/date tie:** PROMPT.md says newest first for emails from the same sender, but does not specify ties on the same date. I chose the email entered first. I rejected arbitrary or reverse ordering.
- **Empty inbox output:** PROMPT.md says NEXT displays the next email but does not specify empty-inbox output. AGENT.md requires `No emails to read.` I used that message and rejected silent NEXT output.
- **Invalid EMAIL output:** PROMPT.md does not define handling of unknown senders or malformed dates. AGENT.md requires skipping the row and reporting to standard error. I followed that and rejected treating malformed rows as valid.
- **File-open and extra-argument errors:** PROMPT.md describes the filename and standard-input cases, but not failures or extra arguments. AGENT.md requires a standard-error message and status 1 for both. I followed that and rejected silent success on a failed open.
- **Output line endings:** PROMPT.md gives the displayed text but does not define line-ending mechanics. I used ordinary newline-terminated output and rejected extra labels or count changes.

## Token/time and instruction compliance

- Exact token spend and timestamp for the first prompt are not exposed in the information available to me, so I cannot truthfully provide exact values.
- I did not knowingly violate the instruction to write only the named source file during the first task. This report was written only after the user explicitly requested it. The status check showed unrelated existing changes and untracked files; I did not modify them.
