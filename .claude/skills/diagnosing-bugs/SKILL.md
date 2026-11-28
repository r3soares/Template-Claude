---
name: diagnosing-bugs
description: Diagnosis loop for a reported bug or performance regression — red feedback loop first, then minimise, hypothesise, instrument, fix with a regression test. Use when told to debug or diagnose, or when something is reported broken, throwing, wrong or slow. Not for a red verify run (use verify).
---

# Diagnosing Bugs

Adapted from `diagnosing-bugs` in Matt Pocock's skills (github.com/mattpocock/skills,
MIT — see `LICENSE`). A discipline for hard bugs. Skip phases only when explicitly
justified.

For the area you touch, read its part of `docs/architecture/overview.md`, its
`.claude/rules/` file if any, and the related ADRs in `docs/adr/`.

## Redact

This skill has you show commands, outputs and captured artifacts. **Redact every secret
first**: write `<REDACTED>` in its place. Build loops against env vars, so the
credential stays in the environment rather than in what you show. Captured artifacts
carry auth headers: quote only the lines that carry the signal. If the redacted output
is not enough to diagnose the bug, say so and ask the developer.

## Phase 1: Build a feedback loop

**This is the skill.** If you have a **tight** pass/fail signal for the bug (one that
goes red on *this* bug), you will find the cause; bisection, hypothesis-testing and
instrumentation all just consume it. Without one, no amount of staring at code will
save you. Spend disproportionate effort here.

Ways to construct one, in roughly this order:

1. **Failing test** at whatever seam reaches the bug: unit, integration, e2e.
2. **Curl / HTTP script** against a running dev server (isolated: temp `HOME` and data
   dirs, a free port — never the developer's real data).
3. **CLI invocation** with a fixture input, diffing stdout against a known-good snapshot.
4. **Headless browser script** (Playwright, if the project has it) asserting on
   DOM/console/network.
5. **Replay a captured trace** (request, payload, event log) through the code path.
6. **Throwaway harness**: a minimal subset of the system exercising the bug path.
7. **Property / fuzz loop** for "sometimes wrong": many random inputs, look for the
   failure mode.
8. **Bisection harness** when it appeared between two known states (commits, tags,
   versions): automate the check and `git bisect run` it.
9. **Differential loop**: same input through old vs new version (or two configs), diff.
10. **Human in the loop**, last resort: drive the developer with
    `scripts/hitl-loop.template.sh` (in this skill's folder) so the loop stays
    structured.

**Tighten the loop.** Faster (narrow scope, skip unrelated setup), sharper (assert the
specific symptom, not "didn't crash"), deterministic (pin time, seed randomness,
isolate filesystem and network). For non-deterministic bugs, raise the reproduction
rate (loop the trigger, add stress) until it's debuggable.

**Can't build a loop?** Stop and say so. List what you tried. Ask for access to an
environment that reproduces it, a redacted artifact (log, HAR, recording), or
permission for temporary instrumentation. Don't hypothesise without a loop.

**Done when** you can name **one command** you have already run (show it and its
redacted output) that is red-capable (drives the real bug path and asserts the
reported symptom), deterministic, fast (seconds), and runnable unattended. Reading code
to build a theory before this command exists is the failure this skill prevents.

## Phase 2: Reproduce and minimise

Run the loop and watch it go red. Confirm it shows the failure the developer described
(not a nearby one — wrong bug, wrong fix), reproducibly, and capture the exact symptom.
Then shrink the scenario one element at a time, re-running after each cut, until every
remaining element is load-bearing. The minimal repro narrows Phase 3 and becomes the
regression test.

## Phase 3: Hypothesise

Write **3–5 ranked, falsifiable hypotheses** before testing any: "If X is the cause,
then changing Y makes the bug disappear / changing Z makes it worse." No stated
prediction → discard or sharpen it. **Show the ranked list to the developer** — they may
re-rank it instantly — but don't block on an answer.

## Phase 4: Instrument

Each probe maps to one prediction; **change one variable at a time**. Prefer a debugger
or REPL, then targeted logs at the boundaries that separate hypotheses — never "log
everything". **Tag every debug log** with a unique prefix, e.g. `[DEBUG-a4f2]`, so
cleanup is one grep. Performance regressions: measure a baseline first (timing harness,
profiler, query plan), then bisect.

## Phase 5: Fix and regression test

Write the regression test **before the fix**, at a **correct seam** — one that
exercises the real bug pattern as it occurs (follow the `test-plan` skill). If no
correct seam exists, that is a finding: say so, don't add a shallow test that gives
false confidence.

1. Turn the minimal repro into a failing test; watch it fail.
2. Apply the fix; watch it pass.
3. Re-run the Phase 1 loop on the original scenario.
4. `./scripts/verify` green (the `verify` skill if not).

## Phase 6: Clean up and integrate

- [ ] The original repro no longer reproduces.
- [ ] The regression test passes (or the missing seam is documented).
- [ ] No `[DEBUG-` tag left (`grep -rn "\[DEBUG-" . --exclude-dir=.git --exclude-dir=.claude`),
      throwaway harnesses deleted.

Then integrate as a small fix (the `integrate` skill): the commit message states the
hypothesis that turned out correct. If the bug was user-visible, the Phase 1 loop's
before/after is the repro lines for the `acceptance` agent (`integrate` step 4c).
