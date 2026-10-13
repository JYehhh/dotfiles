# prismantis-skins-helper

A small mod that makes the Claude Code transcript breathe, and stops tool calls being hidden.

Written 2026-10-12 for jyeh4.

---

## Read this first if something looks wrong

This mod exists to serve **goals**, not to preserve a particular implementation. Prismantis and skins are both days old and change fast. When they change, this mod's code may become the wrong way to achieve the goal, or may stop being needed at all.

**So the section below is the real document.** The code is disposable. If a future agent finds the code no longer produces the described outcome, the correct move is to re-derive an implementation from the goals, not to preserve what is written here.

---

## The original goals, in full

Each one is stated as the outcome wanted, with the reason, so it can be rebuilt from scratch against whatever the mods do next.

### Goal 1: a blank line above every reply

**Want:** a reply never sits flush against the user's prompt or the last tool row. One blank line of separation.

**Why:** without it the transcript reads as one undifferentiated block and the eye cannot find where an answer begins. The user raised this unprompted and repeatedly, which is how much it matters.

**Original cause:** prismantis's `AssistantMessage` handler returned a row `Box` with no `marginTop`. Its only `rowGap={1}` spaced blocks *within* a reply, which is why paragraphs breathed but the reply itself did not.

**Watch out:** the handler runs once per block, not once per reply. Any fix must apply to the first block only, or the whole message double-spaces. Prismantis exposes `e.props.isFirstOfReply` for exactly this.

### Goal 2: a blank line above the duration line

**Want:** the `Cooked for 12s` line at the end of a turn is separated from the last paragraph of the reply.

**Why:** same reason. It is a different element from the reply, and it read as another paragraph.

**Original cause:** both mods return a bare `<Text>` for it, and Ink's `Text` cannot carry a margin. Any fix has to introduce a `Box`.

**Watch out:** both prismantis and skins register this component, and **neither calls `next`**, so whichever loads first wins permanently and there is no toggle on either side. This does not matter for wrapping, but it does mean the line's *content* is not controllable. If it loses skins' tool count and lines-changed stats, that is load order, not a bug.

### Goal 3: a blank line above the spinner

**Want:** the working spinner is separated from whatever is above it.

**Why:** same reason again.

**Watch out:** the spinner is replaced by the duration line when a turn ends. Goals 2 and 3 must use the **same** amount of space, or the transcript jumps by a line at that moment.

### Goal 4: never collapse tool calls

**Want:** every tool call draws as its own row, showing its command. A batch of four is four rows.

**Why:** the user explicitly said "I want nothing to collapse, everything to be expanded out". They like watching commands run as they go.

**Original cause:** skins' `ToolGroup` handler replaced an unexpanded batch with a tally counting calls by kind. It did this even for a group of **one**, turning `Ran grep ...` into `Run 1`, which loses the command and saves no space. That single-call case is arguably an upstream bug and is worth reporting.

**Watch out:** this is the only goal here that cannot be met by wrapping, because the aim is to stop another mod drawing rather than to decorate what it drew. See the implementation note below.

---

## How the current implementation works

One idea carries three of the four goals.

`next(e)` runs the plugins beneath this one and resolves to **whatever they drew**. So this mod never competes for the draw. It lets prismantis or skins render, then wraps the returned element:

```tsx
const theirs = await next(e)
return <Box marginTop={1}>{theirs}</Box>
```

That is why it should survive upstream changes. It does not know or care what the other mods produce, only that they produce something.

**Goal 4 is the exception.** Wrapping cannot help, because the aim is suppression. Rather than fighting for the draw, it rewrites the event:

```tsx
next({ ...e, props: { ...e.props, isExpanded: true } })
```

Both prismantis and skins check `isExpanded` and step back when it is true, so claiming the group is already expanded makes them both hand it to Claude Code's own renderer.

**This is the fragile one, for two reasons.** It depends on load order, because it only works while this mod sits above the others in the chain. And it depends on both mods continuing to honour `isExpanded`. If batches start collapsing again, check those two things before assuming the condition is broken.

---

## Settings

All four behaviours are independently switchable in `/config` under this mod.

| Setting | Default | Goal |
|---|---|---|
| `replyGap` | on | 1 |
| `durationGap` | on | 2 |
| `spinnerGap` | on | 3 |
| `expandToolGroups` | on | 4 |

---

## What this replaces

Four hand-edits inside the two mods' source, made 2026-10-12 and now obsolete:

| Was | File |
|---|---|
| Never collapse tool groups | `skins/0.1.1/hooks/register.tsx` |
| Gap above each reply | `prismantis/0.12.0/hooks/register.tsx` |
| Gap above the duration line | `prismantis/0.12.0/hooks/render.tsx` |
| Gap above the spinner | `skins/0.1.1/hooks/rows.tsx` |

**All four must be reverted once this mod is confirmed working**, or the margins double. Each carries a `LOCAL PATCH (jyeh4, 2026-10-12)` comment with revert instructions, so this finds them:

```bash
grep -rn "LOCAL PATCH" \
  ~/.claude/plugins/cache/hellosverre-mods/skins/*/hooks/ \
  ~/.claude/plugins/cache/prismantis/prismantis/*/hooks/
```

The reason for moving them here: plugins install into version-numbered folders, so a patched file is left behind on every update and silently stops being loaded. Nothing warns you. A mod is not affected by that.

---

## Context

**The two mods and what each is for.** Prismantis colours the prose: headings, tables, code, links, diagrams. Skins styles the furniture: tool rows, spinner, prompt, context band. The division is forced rather than chosen, because prismantis can step back from tool rows but not tables, and skins can step back from tables but not tool rows. The reverse arrangement is impossible.

**Why any of this exists.** The user found Claude Code replies hard to read. A terminal has one font size, so heading hierarchy is impossible without a mod. Everything here is downstream of that.

**Wider notes** on configuration, conflicts, rendering facts established by testing, and the writing-style work live in `~/.claude/fixing-verbosity/README.md`.

---

## Developing it

```bash
claude plugin validate ~/.claude/dev-mods/d67e4f12-2ac9-4aab-838a-ef26338ea807/prismantis-skins-helper
```

Edits reload when the turn that made them ends, while hot reloading is on for the session. In a fresh session:

```bash
claude --plugin-dir ~/.claude/dev-mods/d67e4f12-2ac9-4aab-838a-ef26338ea807
```

To make it permanent rather than a dev mod, move the folder somewhere stable and add that directory to `CLAUDE_CODE_PLUGIN_DIRS`, or push it to a repo with a marketplace manifest and install it normally.
