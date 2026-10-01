# EECS 348 Assignment 3: Email Prioritizer (C++ Objects)

Write a C++ program using objects (not functions) that prioritizes emails for a busy company CEO using a MaxHeap.

## Requirements

- **Use a MaxHeap** as a priority queue to prioritize emails.
- **Implement MaxHeap using a list-based implementation** (vector or array). Create objects from scratch—do not use pre-existing heap modules or libraries.
- **Create an Email class** to represent an email with sender category, subject line, and date.
- **Create a MaxHeap class** with methods to insert, extract the maximum (highest priority) email, and get the count.

## Priority Rules

1. **Primary**: Sender category (highest to lowest):
   - Boss
   - Subordinate
   - Peer
   - ImportantPerson
   - OtherPerson

2. **Tiebreaker**: Within the same sender category, **newest email first** (most recent date).
   - Date format: `MM-DD-YYYY`
   - Do NOT use string comparison; convert dates to a numeric format (e.g., `YYYYMMDD` as an integer) or compare fields numerically.

## Commands (read from input file)

- **EMAIL <sender_category>,<subject_line>,<date>**
  - Add an email to the inbox.
  - Subject line may contain spaces but not commas.
  - Sender category is one of: Boss, Subordinate, Peer, ImportantPerson, OtherPerson.

- **NEXT**
  - Display the next (highest priority) email in the format:
    ```
    Next email:
      Sender: <sender_category>
      Subject: <subject_line>
      Date: <date>
    ```
  - If no emails, handle gracefully (no output or an error message, but do not crash).

- **READ**
  - Remove and discard the highest priority email from the heap.
  - If no emails, handle gracefully.

- **COUNT**
  - Display the count of unread emails in the format: `There are <N> emails to read.`

## Input Format

- Read commands from a file (filename as a command-line argument, or stdin).
- Each line is a single command or email entry.
- Parse EMAIL lines carefully: split on commas, but the subject may contain spaces.

## Edge Cases (must handle)

- NEXT or READ when the inbox is empty.
- Two NEXTs in a row without an intervening READ (output should be identical both times).
- Two READs in a row without an intervening NEXT (highest priority email removed without being displayed).

## Example

**Input:**
```
EMAIL Peer,Can you help me on this?,12-01-2024
EMAIL OtherPerson,Try our product,12-19-2024
EMAIL Boss,Important,12-20-2024
EMAIL Subordinate,How do I handle this?,12-25-2024
EMAIL ImportantPerson,Health Insurance Enrollment,12-31-2024
EMAIL Boss,Never Mind,01-03-2025
COUNT
NEXT
READ
NEXT
READ
COUNT
```

**Output:**
```
There are 6 emails to read.

Next email:
  Sender: Boss
  Subject: Never Mind
  Date: 01-03-2025

Next email:
  Sender: Boss
  Subject: Important
  Date: 12-20-2024

There are 4 emails to read.
```

---

**NOTE**: This is the same program as Assignment 2 (C version with functions). The difference is that Assignment 3 uses **C++ with classes/objects** to implement the heap and email structure.
