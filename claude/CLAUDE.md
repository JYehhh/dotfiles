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
