---
name: grill-me
description: Interview the developer relentlessly about a plan, design or decision until every branch is settled, then hand off to feature-spec or adr. Use when asked to grill, stress-test or poke holes in a plan, or before a spec when key decisions are still open.
---

# Grill me

Adapted from `grilling` in Matt Pocock's skills (github.com/mattpocock/skills, MIT —
see `LICENSE`).

Interview the developer relentlessly until you reach a shared understanding. Map it as
a **design tree**: every decision branches into the decisions that hang off it. Talk in
the conversation language (`Reply to the developer in:` in `CLAUDE.md`).

## Rounds

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are
already settled: the questions you can ask *now* without guessing at answers you
haven't heard yet. Ask the whole frontier in one round: number each question and give
your recommended answer. Then wait for the answers before the next round.

Format a round like so:

```text
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body>

➡️ <your recommended answer>
```

Word each question so "yes" accepts your recommended answer.

Each round reshapes the tree: settled decisions push the frontier outward and unblock
questions that depended on them. Recompute the frontier and ask the next round. A
question whose answer depends on another question still open in this round belongs to
a *later* round. A question the developer skipped stays on the frontier.

## Facts are yours, decisions are theirs

Finding *facts* is your job, never the developer's. When a question needs a fact from
the project — how something works today, what a file says, which module owns it —
look it up (read the code, `docs/architecture/overview.md`, the ADRs; send a broad
sweep to the `Explore` agent). Don't block on it: only the questions downstream of a
running lookup wait; ask the rest of the frontier now. The *decisions* are the
developer's: put each to them and wait.

## Done

The session is done when the frontier is empty: every branch visited, nothing left
silently assumed. Write no files during the interview, and don't act on it until the
developer confirms you have reached a shared understanding. Then sum up the settled
decisions and offer the next step:

- a feature or user-facing change → the `feature-spec` skill (the decisions fill Impact,
  Scope and the Finish Line; nothing should be left for Open Questions);
- one hard-to-reverse technical choice → the `adr` skill.
