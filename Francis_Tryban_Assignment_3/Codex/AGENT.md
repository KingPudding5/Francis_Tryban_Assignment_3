# AGENT.md

Standing rules for this folder. PROMPT.md says what the program must do. This
file says how it must be written. Both apply. If they ever conflict, PROMPT.md
wins.

## Who is reading this code

Me. I have about a year of Python and a little C, and almost no C++. Write for
that reader.

## Header

One block comment at the very top of the .cpp file, before any `#include`.
Once, nowhere else. All ten of these, each on its own line, with exactly this
content where it is given:

- Program name: EECS 348 Assignment 3
- Brief description: C++ program that prioritizes a CEO's emails with a
  list-based MaxHeap built from scratch
- Inputs: a test file of EMAIL, NEXT, READ and COUNT commands, named on the
  command line or piped in on standard input
- Outputs: email counts and the next email to read, printed to the terminal
- Author: Francis Tryban
- Creation date: 10-01-2026
- Revision date: 10-01-2026
- Revisions: rewrote run 00 under AGENT.md rules (comments, prolog, input
  cleanup, error messages, one method per command)
- Collaborators: none
- Other sources: OpenAI Codex (GPT-6 Luna) generated this code from my
  specification; Claude Opus 5.5 helped me write the rules in AGENT.md

## Comments

Every line gets a comment. Match this style — it is mine, copy it:

```cpp
#include <iostream> // include the iostream library
int main() { // define the program's main entry point, returning an int
	int num1 = 10; // define num1 as an int holding 10
	std::cout << "Maximum of " << num1 << std::endl;
	// ^ print the answer as a sentence
	return 0; // exit the program and return 0
} // end of main
```

- Short, lowercase, on the same line, no period on the end.
- Say what the line does in plain words. Do not restate the syntax.
- The first time a piece of C++ notation shows up, explain it once in plain
  words: `std::`, `&` in a parameter, `const`, `*`, `nullptr`, `size_t`,
  `std::vector`, `std::string::npos`, `argc`/`argv`, `private`/`public`,
  constructor initializer lists.
- If the line is too long to comment on the end, put the comment on the next
  line starting with `// ^`.
- Close every class and function with `} // end of <name>`.
- Above every class and every function, one summary line that says what the
  block does and where it came from, ending in exactly
  `(source: Codex GPT-6 Luna)`.
- Write them the way I would. Short and plain beats polished.

## Objects, not functions

- Everything lives inside a class except `main`. No free-standing helper
  functions.
- Each command gets its own member function: one for EMAIL, one for NEXT, one
  for READ, one for COUNT. A separate method reads lines and hands each one to
  the right command.
- `main` only picks the input source and starts the program object.
- Do not use `std::priority_queue`, `<queue>`, `std::make_heap`,
  `std::push_heap`, `std::pop_heap` or `std::sort`. Build the heap yourself on a
  `std::vector`.

## Correctness

- Keep these from the first version: the sender rank and the date number are
  worked out once when an email is created, not on every comparison; a tie on
  sender category and date goes to the email that came first in the file; the
  heap checks for an empty list itself instead of trusting its caller.
- Strip spaces, tabs and `\r` from both ends of every line and of each EMAIL
  field before using it. `COUNT `, ` COUNT` and `EMAIL Boss, Hi, 01-02-2025`
  must work.
- `NEXT` on an empty inbox prints `No emails to read.` Never print nothing.
- `READ` on an empty inbox does nothing and prints nothing.
- `COUNT` always prints `There are N emails to read.` exactly as in PROMPT.md.
- An EMAIL line that does not have a known sender category, a subject, and a
  date of the form `MM-DD-YYYY` made of digits is skipped. Print one line
  explaining why to standard error, never to standard output, and keep going.
  The program must never crash on bad input.
- A file that cannot be opened: print an error to standard error and exit
  with status 1.
- More than one command-line argument: print usage to standard error and exit
  with status 1.
- Pass strings by `const` reference, not by value.
- It must compile with no warnings under
  `g++ -Wall -Wextra -Wconversion -O2 file.cpp -o file` and under the plain
  `g++ file.cpp -o file`.

## Scope

Write only the file the run instruction names. Do not create, rename, or edit
anything else. Do not add features nobody asked for.
