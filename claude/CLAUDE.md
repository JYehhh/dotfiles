# Global preferences

## Writing style

Never use em dashes (—). This applies everywhere: chat responses, code comments, commit messages, PR descriptions and comments, docs, and any other written output.

Use a comma, colon, parentheses, or a separate sentence instead.

En dashes (–) are fine and the user likes them. Hyphens are fine.

Everything else about how to write, meaning scope, structure and sentences:

@~/.claude/writing-style.md

## Spawning agents

The `Agent` tool has two shapes with very different context budgets. Choose deliberately
based on the kind of work, and say which you picked and why.

**Unnamed subagent** (no `name` param): inherits Opus 5 with the 1M context window,
measured to 803k in practice. Runs, returns a result, exits. Still resumable later via
the `agentId` it returns.

**Named teammate** (`name` param set): spawns its own session and currently runs
Opus 4.7, which has no 1M variant and is capped at 200k.

Choosing between them:

- Delegatory work (fan-out research, log sweeps, parallel file reads, anything that
  eats context and reports back once) goes to subagents. The 1M window is a 5x
  advantage and these tasks rarely need a conversation.
- Communicatory work (agents coordinating with each other or with the user across
  many turns, where the mailbox is the point) is what teammates are for.
- A teammate is a fine choice, just budget for 200k. If a teammate's job involves
  heavy reading, split that part off to a subagent and let the teammate handle the
  coordination.

Two operational rules:

- Always pass `model: "opus"` when spawning a teammate. Without it they silently
  default to Opus 4.7 even though `ANTHROPIC_MODEL` is set to `claude-opus-5[1m]`.
- Teammates stay alive and idle after finishing their work. `TaskStop` them once
  they're done rather than leaving them parked.

## Daily Diary (recalling past work)

The user runs claude-nine's Daily Diary plugin, which auto-summarizes Claude Code session activity
(and manual "Force save entry now" triggers) into `~/Daily Diary/YYYY-MM-DD.md` -- one markdown file
per day (including TODAY -- entries land there throughout the day, not just at day's end), under a
`## Sessions` heading, each entry like `### HH:MM -- <session-name>` followed by a short summary of
what was investigated/done. This is a PASSIVE, AUTOMATIC record covering every session, whether or
not the user ever explicitly tracked that work anywhere.

**Check this diary whenever the user asks about their own day or past activity in ANY form** -- not
just explicit "recall" phrasing. This includes casual check-ins ("how's my day going so far", "what
have I been up to", "catch me up on today"), explicit lookups ("what did I do yesterday", "when did
I work on X", "summarize last week"), and anything else asking what happened or was done on a given
day. Default to checking the diary rather than answering from this conversation's own context alone
or from memory -- a question like "how's my day going" is about the user's ACTUAL day across ALL
their sessions, not just this one conversation.

Read the relevant date file(s) from `~/Daily Diary/` (`ls ~/Daily Diary/` to see what's available,
`date +%Y-%m-%d` for today, or `date -v-Nd +%Y-%m-%d` style math for "N days ago"). If a requested
date has no file, say so plainly rather than guessing.

**If a `/wip` skill is also installed:** it tracks a different thing -- explicit, user-curated work
streams the user deliberately started with `/wip start`, not everything they did. A question framed
around *ongoing/ open* work ("what am I working on", "what's on my plate", "what's next") is wip's
territory; check wip first for those. A question framed around *what already happened* ("how'd my
day go", "what did I do yesterday") is this diary's territory. When a question could reasonably mean
either (e.g. "catch me up"), check both and combine them -- the diary fills in activity that was
never tracked as a wip.
