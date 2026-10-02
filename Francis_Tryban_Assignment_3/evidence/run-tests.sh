#!/usr/bin/env bash
#
# run-tests.sh -- comparison bench for EECS 348 Assignment 3 (C++, objects).
#
# PROVENANCE: written by Claude Opus 5.5 (Anthropic, extra effort) at my
# direction on 2026-10-01, adapted from my Assignment 2 bench (which Claude
# Opus 5 wrote). Sections 0, 3, 5, 7 and 9 are carried over with C changed to
# C++. Section 4 has new cases for things the two C++ programs do differently.
# Section 6 replaces the Assignment 2 overflow probe (neither program here can
# overflow its date key) with a probe of malformed dates. The Assignment 2
# source diff is dropped: diffing two unrelated programs line by line is noise.
#
# It is a measuring instrument, not a grader. It never decides pass or fail. It
# runs both programs through identical inputs and prints exactly what each did.
# All scratch files go in a temporary directory, never next to the sources.
#
# Usage:  ./run-tests.sh <claude.cpp> <codex.cpp>
#         LABEL_A=codex00 LABEL_B=codex01 ./run-tests.sh <a.cpp> <b.cpp>  (other names)

set -u
A_SRC=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
B_SRC=$(cd "$(dirname "$2")" && pwd)/$(basename "$2")
A=${LABEL_A:-claude}; B=${LABEL_B:-codex}
WORK=$(mktemp -d); cd "$WORK" || exit 1
cp "$A_SRC" "$A.cpp"; cp "$B_SRC" "$B.cpp"
rule() { printf '\n=== %s ===\n' "$1"; }

# --------------------------------------------------------------------------
# 0. Environment. Numbers only mean something against the machine that made them.
# --------------------------------------------------------------------------
rule "ENVIRONMENT"
uname -m; g++ --version | head -1; ldd --version 2>&1 | head -1; date
echo "sources: $A_SRC"; echo "         $B_SRC"

# --------------------------------------------------------------------------
# 1. Compilation under several flag sets. The same file can be silent under one
#    set and complain under another. -Wconversion is new for C++: it flags
#    silent narrowing such as storing a vector size (size_t) in an int.
#    -std=c++98 shows which C++11 features each program depends on.
# --------------------------------------------------------------------------
for flags in "" "-Wall -Wextra" "-O2" "-Wall -Wextra -O2" "-Wall -Wextra -Wconversion" "-std=c++11 -pedantic" "-std=c++98 -pedantic"; do
    rule "COMPILE: g++ ${flags:-<plain command, no flags>}"
    for p in "$A" "$B"; do
        echo "--- $p.cpp ---"; g++ $flags "$p.cpp" -o /dev/null 2>&1 | grep -E 'error|warning' | head -8; echo "exit=${PIPESTATUS[0]}"
    done
done

# --------------------------------------------------------------------------
# 2. Build the working binaries with the plain command the grader is assumed
#    to use.
# --------------------------------------------------------------------------
g++ "$A.cpp" -o "$A"; g++ "$B.cpp" -o "$B"

# --------------------------------------------------------------------------
# 3. Byte-exact check against the sample printed in PROMPT.md, both input paths.
# --------------------------------------------------------------------------
cat > sample.txt <<'EOT'
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
EOT
cat > expected.txt <<'EOT'
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
EOT
rule "SPEC SAMPLE: byte-exact, both input paths"
for prog in "$A" "$B"; do
    for mode in arg stdin; do
        if [ "$mode" = arg ]; then "./$prog" sample.txt > "got.txt" 2>/dev/null
        else "./$prog" < sample.txt > "got.txt" 2>/dev/null; fi
        if diff -q expected.txt got.txt >/dev/null; then echo "  $prog ($mode): BYTE-IDENTICAL"
        else echo "  $prog ($mode): DIFFERS"; diff expected.txt got.txt | sed 's/^/      /'; fi
    done
done

# --------------------------------------------------------------------------
# 4. Behavior. First the cases the assignment names but never shows output
#    for, then inputs outside the stated format. The assignment says the
#    grader's file will be "formatted as shown", so the second group is about
#    robustness, not about meeting the spec. Exit 134 means the program
#    aborted (crashed). Labels must not contain a colon: the first colon
#    separates the label from the input.
# --------------------------------------------------------------------------
CASES_IN=(
  "NEXT on empty inbox:NEXT\n"
  "READ on empty inbox:READ\n"
  "COUNT on empty inbox:COUNT\n"
  "COUNT with exactly one:EMAIL Boss,Solo,01-01-2025\nCOUNT\n"
  "two NEXTs, no READ between:EMAIL Boss,A,01-01-2025\nNEXT\nNEXT\n"
  "two READs, no NEXT between:EMAIL Boss,A,01-01-2025\nEMAIL Boss,B,01-02-2025\nREAD\nREAD\nCOUNT\n"
  "READ more times than there are emails:EMAIL Boss,A,01-01-2025\nREAD\nREAD\nREAD\nCOUNT\nNEXT\n"
  "tie, same sender AND same date, x3:EMAIL Boss,FIRST,01-01-2025\nEMAIL Boss,SECOND,01-01-2025\nEMAIL Boss,THIRD,01-01-2025\nNEXT\nREAD\nNEXT\nREAD\nNEXT\n"
  "all five categories, same date:EMAIL OtherPerson,E,01-01-2025\nEMAIL ImportantPerson,D,01-01-2025\nEMAIL Peer,C,01-01-2025\nEMAIL Subordinate,B,01-01-2025\nEMAIL Boss,A,01-01-2025\nNEXT\nREAD\nNEXT\nREAD\nNEXT\nREAD\nNEXT\nREAD\nNEXT\n"
  "date ordering crosses a year:EMAIL Boss,OLD,12-31-2024\nEMAIL Boss,NEW,01-01-2025\nNEXT\n"
  "same year, month decides over day:EMAIL Peer,FEB01,02-01-2025\nEMAIL Peer,JAN31,01-31-2025\nNEXT\n"
  "subject containing spaces:EMAIL Boss,A subject with many spaces,01-01-2025\nNEXT\n"
  "emails added after reading started:EMAIL Peer,P,01-01-2025\nNEXT\nEMAIL Boss,B,01-01-2020\nNEXT\nCOUNT\n"
  "empty file:"
)
CASES_OUT=(
  "Windows line endings (CRLF):EMAIL Boss,A,01-01-2025\r\nEMAIL Peer,B,01-02-2025\r\nCOUNT\r\nNEXT\r\n"
  "blank lines in the file:\n\nEMAIL Boss,A,01-01-2025\n\nCOUNT\n"
  "trailing space after a command:EMAIL Boss,A,01-01-2025\nCOUNT \nNEXT \n"
  "leading space before a command: EMAIL Boss,A,01-01-2025\n COUNT\n"
  "spaces after the commas:EMAIL Boss,Older,01-01-2025\nEMAIL Boss, Newer, 01-02-2025\nNEXT\n"
  "unknown sender category:EMAIL Alien,X,01-02-2025\nEMAIL OtherPerson,Y,01-01-2025\nCOUNT\nNEXT\n"
  "EMAIL line with no commas:EMAIL garbage with no commas\nCOUNT\n"
  "EMAIL line with no date:EMAIL Boss,Has a date,01-01-2025\nEMAIL Boss,No date\nCOUNT\nNEXT\n"
  "non-numeric date:EMAIL Boss,Good,01-01-2025\nEMAIL Boss,Bad,xx-yy-zzzz\nCOUNT\nNEXT\n"
  "lowercase command:EMAIL Boss,A,01-01-2025\ncount\nnext\n"
)
run_cases() {
    for prog in "$A" "$B"; do
        printf '\n######## %s ########\n' "$prog"
        for case in "$@"; do
            label="${case%%:*}"; input="${case#*:}"
            printf -- '--- %s ---\n' "$label"
            printf "$input" > case.txt
            timeout 5 "./$prog" case.txt 2>&1 | sed 's/^/    /'; echo "    [exit=${PIPESTATUS[0]}]"
        done
    done
}
rule "RESULTS: inside the stated format"; run_cases "${CASES_IN[@]}"
rule "RESULTS: outside the stated format"; run_cases "${CASES_OUT[@]}"
rule "BEHAVIOR: command line"
for prog in "$A" "$B"; do
    printf 'COUNT\n' > case.txt
    out=$("./$prog" case.txt extra 2>&1); ec=$?; printf '  %-6s extra argument  -> %-32s [exit=%s]\n' "$prog" "${out:-<no output>}" "$ec"
    out=$("./$prog" no_such_file.txt 2>&1); ec=$?; printf '  %-6s missing file    -> %-32s [exit=%s]\n' "$prog" "${out:-<no output>}" "$ec"
done

# --------------------------------------------------------------------------
# 5. Heap-order oracle. 500 random emails with no duplicate (sender, date)
#    pairs, so the different tie-break rules cannot matter. Each program drains
#    its queue and the order is compared against an independent Python sort.
# --------------------------------------------------------------------------
rule "HEAP ORDER ORACLE (500 emails, no ties)"
python3 - "$A" "$B" <<'PYEOF'
import random, subprocess, sys
random.seed(348)
CATS=["Boss","Subordinate","Peer","ImportantPerson","OtherPerson"]
RANK={c:5-i for i,c in enumerate(CATS)}
N=500; seen=set(); rows=[]
while len(rows)<N:
    c=random.choice(CATS); m=random.randint(1,12); d=random.randint(1,28); y=random.randint(2000,2030)
    if (c,m,d,y) in seen: continue
    seen.add((c,m,d,y)); rows.append((c,f"Subj{len(rows)}",f"{m:02d}-{d:02d}-{y:04d}",y*10000+m*100+d))
with open('oracle.txt','w') as f:
    for c,s,dt,_ in rows: f.write(f"EMAIL {c},{s},{dt}\n")
    for _ in rows: f.write("NEXT\nREAD\n")
expected=[s for c,s,dt,k in sorted(rows,key=lambda r:(-RANK[r[0]],-r[3]))]
for prog in sys.argv[1:3]:
    out=subprocess.run([f"./{prog}","oracle.txt"],capture_output=True,text=True).stdout
    got=[l.split("Subject: ",1)[1] for l in out.splitlines() if l.startswith("Subject: ")]
    if got==expected: print(f"  {prog}: order CORRECT for all {N}")
    else:
        i=next((i for i,(g,e) in enumerate(zip(got,expected)) if g!=e), min(len(got),len(expected)))
        print(f"  {prog}: WRONG at position {i} -- got {got[i] if i<len(got) else 'EOF'}, expected {expected[i]}")
PYEOF

# --------------------------------------------------------------------------
# 6. Undefined-behavior check. Runs every behavior case again under the
#    address and undefined-behavior sanitizers, which catch reads past the end
#    of a vector and similar bugs that may not show up in normal output.
# --------------------------------------------------------------------------
rule "SANITIZERS: every behavior case under -fsanitize=address,undefined"
for prog in "$A" "$B"; do
    g++ -g -fsanitize=address,undefined "$prog.cpp" -o "${prog}_san" 2>/dev/null || { echo "  $prog: sanitizer build failed"; continue; }
    n=0; bad=0
    for case in "${CASES_IN[@]}" "${CASES_OUT[@]}" "oracle:"; do
        label="${case%%:*}"; input="${case#*:}"
        if [ "$label" = oracle ]; then cp oracle.txt case.txt; else printf "$input" > case.txt; fi
        n=$((n+1))
        rep=$(ASAN_OPTIONS=detect_leaks=1 timeout 10 "./${prog}_san" case.txt 2>&1 >/dev/null | grep -E 'ERROR: AddressSanitizer|runtime error|LeakSanitizer|terminate called' | head -1)
        [ -n "$rep" ] && { bad=$((bad+1)); printf '  %-6s %-40s %s\n' "$prog" "$label" "$rep"; }
    done
    echo "  $prog: $bad of $n cases reported a problem"
done

# --------------------------------------------------------------------------
# 7. Execution time. Three sizes, best of three, user CPU only. Two builds:
#    the plain command (what the grader runs) and -O2.
# --------------------------------------------------------------------------
rule "EXECUTION TIME: scaling, user CPU seconds, best of 3"
TIMEFORMAT='%3U'
for opt in "" "-O2"; do
    for p in "$A" "$B"; do g++ $opt "$p.cpp" -o "${p}_t" 2>/dev/null; done
    echo "  build: g++ ${opt:-<plain>}"
    printf '    %-9s %-10s %-10s\n' "N emails" "$A" "$B"
    for n in 5000 50000 500000; do
        python3 -c "
import random;random.seed(1)
C=['Boss','Subordinate','Peer','ImportantPerson','OtherPerson']
w=open('scale.txt','w')
for i in range($n): w.write('EMAIL %s,S%d,%02d-%02d-%04d\n'%(random.choice(C),i,random.randint(1,12),random.randint(1,28),random.randint(2000,2030)))
for i in range($n): w.write('NEXT\nREAD\n')"
        printf '    %-9s' "$n"
        for p in "$A" "$B"; do
            best=999
            for r in 1 2 3; do
                t=$( { time "./${p}_t" scale.txt > /dev/null; } 2>&1 )
                best=$(python3 -c "print(min($best,$t))")
            done
            printf ' %-10s' "${best}s"
        done
        echo
    done
done

# --------------------------------------------------------------------------
# 8. Space. Stack frame per function (from -fstack-usage, user code only),
#    the size of one Email object, and peak memory with 100,000 emails held at
#    once (max resident set size; five runs, because one run is noise).
# --------------------------------------------------------------------------
rule "SPACE: largest stack frames in the program's own functions"
for p in "$A" "$B"; do
    g++ -fstack-usage -c "$p.cpp" -o /dev/null 2>/dev/null
    echo "  --- $p ---"
    grep "^$p.cpp" "$p.su" 2>/dev/null | sort -t$'\t' -k2 -rn | head -4 | awk -F'\t' '{f=$1; sub(/^[^:]*:[0-9]+:[0-9]+:/,"",f); printf "     %-55s %s bytes\n",f,$2}'
done

rule "SPACE: sizeof(Email)"
for p in "$A" "$B"; do
    { echo '#include <cstdio>'; sed 's/int main(/int original_main(/' "$p.cpp"
      echo 'int main(){std::printf("%zu", sizeof(Email));return 0;}'; } > "sz_$p.cpp"
    g++ "sz_$p.cpp" -o "sz_$p" 2>/dev/null && printf '  %-6s sizeof(Email) = %s bytes\n' "$p" "$(./sz_$p)"
done

rule "SPACE: peak memory, 100,000 emails held at once (max RSS, KB, 5 runs)"
python3 -c "
import random;random.seed(7)
C=['Boss','Subordinate','Peer','ImportantPerson','OtherPerson']
w=open('mem.txt','w')
for i in range(100000): w.write('EMAIL %s,Subject number %d with some words,%02d-%02d-%04d\n'%(random.choice(C),i,random.randint(1,12),random.randint(1,28),random.randint(2000,2030)))
w.write('COUNT\n')"
for p in "$A" "$B"; do
    runs=""
    for r in 1 2 3 4 5; do
        kb=$( { /usr/bin/time -f '%M' "./$p" mem.txt > /dev/null; } 2>&1 | tail -1 ); runs="$runs $kb"
    done
    printf '  %-6s %s\n' "$p" "$runs"
done
printf 'COUNT\n' > tiny.txt
for p in "$A" "$B"; do
    kb=$( { /usr/bin/time -f '%M' "./$p" tiny.txt > /dev/null; } 2>&1 | tail -1 )
    printf '  %-6s baseline with no emails: %s KB\n' "$p" "$kb"
done
command -v valgrind >/dev/null 2>&1 || echo "  (valgrind not installed here; leak check is covered by the sanitizer section)"

# --------------------------------------------------------------------------
# 9. Maintainability, counted rather than asserted.
# --------------------------------------------------------------------------
rule "MAINTAINABILITY: size and structure"
printf '  %-7s %6s %6s %8s %8s %10s\n' "file" "lines" "blank" "comment" "classes" "free fns"
for p in "$A" "$B"; do
    tot=$(grep -c '' "$p.cpp"); bl=$(grep -cE '^[[:space:]]*$' "$p.cpp")
    cm=$(grep -cE '//|/\*' "$p.cpp"); cl=$(grep -cE '^class ' "$p.cpp")
    fr=$(grep -cE '^[A-Za-z].*\(.*\)[[:space:]]*\{[[:space:]]*(//.*)?$' "$p.cpp")
    printf '  %-7s %6s %6s %8s %8s %10s\n' "$p" "$tot" "$bl" "$cm" "$cl" "$fr"
done
for p in "$A" "$B"; do
    echo "  --- $p: functions outside any class ---"
    grep -nE '^[A-Za-z].*\(.*\)[[:space:]]*\{[[:space:]]*(//.*)?$' "$p.cpp" | sed 's/^/     line /'
done

rule "MAINTAINABILITY: rubric prolog items present in the first 25 lines"
for p in "$A" "$B"; do
    echo "  --- $p.cpp ---"
    head -25 "$p.cpp" > hdr.tmp
    while IFS='|' read -r label pat; do
        if grep -qiE "$pat" hdr.tmp; then r="present"; else r="MISSING"; fi
        printf '     %-22s %s\n' "$label" "$r"
    done <<'EOT'
program name|EECS|348|Assignment
brief description|escription
inputs|[Ii]nput
outputs|[Oo]utput
author full name|uthor|Tryban
creation date|reated|[Dd]ate:
revision date|evision
collaborators|ollaborat
other sources / GenAI|ChatGPT|Codex|Claude|GenAI|OpenAI|Anthropic
EOT
done

cd /; rm -rf "$WORK"
echo; echo "=== done ==="
