# fixing-verbosity

Notes for any agent working on jyeh4's Claude Code reading experience.

Written 2026-10-12. Lives in `~/.claude/` because everything it documents lives there too.

---

## Status, read before the rest

**The "Manual patches to maintain" section below is history, not instructions.** Those four hand-edits were applied and then reverted the same day. Both mods are now pristine upstream source. Do not go looking for them.

They were replaced by a third mod, written to do the same four jobs in a way that survives plugin updates:

| | Where |
|---|---|
| The mod | `~/.claude/dev-mods/<session-id>/prismantis-skins-helper/` |
| Its goals, which are the real document | that folder's `README.md` |
| The four original patches, verbatim | `./original-patches.md` next to this file |

The patch section is kept because the diffs are still the clearest statement of what was wrong with the upstream code, and `original-patches.md` holds both directions verbatim if a direct patch is ever needed as a fallback.

Also now done, which the open-items list below does not yet reflect: `~/.claude/writing-style.md` is written, with all three layers. It is **not yet imported** from `CLAUDE.md`, so it has no effect until this line is added there:

```markdown
@~/.claude/writing-style.md
```

---

## The goal

Claude Code replies were hard to read. Three distinct failures, named by the user:

1. **Density.** Individual sentences needed re-reading. The original example was a table cell reading `The alert body misdirects the majority case`, which contains no jargon but stacks three abstractions before the reader gets a concrete noun.
2. **Organisation.** Couldn't find the thread through a long reply.
3. **Volume.** Not one long reply, but many in a row. Fatigue is cumulative.

Two separate workstreams came out of that:

- **Rendering.** Make the terminal capable of showing hierarchy. Mostly done, documented below.
- **Writing style.** Rules telling the model how to write. Partly drafted, not yet written to a file. See the last section.

A constraint the user stated explicitly and which matters more than anything else here:

> The first summary block is the only part I read word for word, every time. From the section map onward I skim.

---

## What is installed

Two third-party "mods" (plugins using the function-hooks API that shipped in Claude Code 2.1.287). Both are TypeScript running inside Claude Code's Node process. **Neither makes any network calls**, verified by grep on 2026-10-09.

| Mod | Version | Marketplace | Job |
|---|---|---|---|
| [prismantis](https://github.com/NahumLitvin/prismantis) | 0.12.0 | `NahumLitvin/prismantis` | Colours the prose: headings, tables, code, links, diagrams |
| [skins](https://github.com/hellosverre/claude-skins) | 0.1.1 | `hellosverre/claude-skins` | Styles the furniture: tool rows, spinner, prompt, context band |

Both repos were created 2026-10-02 and are very actively developed. Expect frequent version bumps, which is the main maintenance risk.

---

## Manual patches to maintain

**Two patches. Both will silently revert on a plugin update**, because plugins install into version-numbered directories and the patched file is left behind in the old one. Nothing will warn you. The symptom is the old behaviour quietly returning.

After any plugin update, check both and re-apply.

### Patch 1: skins never collapses tool groups

```
~/.claude/plugins/cache/hellosverre-mods/skins/0.1.1/hooks/register.tsx
```

Around line 445. The whole handler body is replaced with a pass-through.

**Before:**
```tsx
on('ui.render', { component: 'ToolGroup' }, async ($, e, next) => {
  const active = await activeSkin($)
  if (active === null || e.props.isExpanded) {
    return next(e)
  }
  return groupRow(lookOf($.ui.resolve(e), active, e.surface), e.props.calls)
})
```

**After:**
```tsx
on('ui.render', { component: 'ToolGroup' }, async (_$, e, next) => next(e))
```

**Why.** Skins replaced an unexpanded batch of tool calls with a tally like `Run 1`, hiding the command. The user wants every call visible. Note the original collapsed even a group of **one**, which summarises nothing and loses the command name, so that part is arguably an upstream bug worth reporting.

**Side effect.** `groupRow` becomes an unused import from `./rows`. Harmless.

### Patch 2: prismantis adds a blank line above each reply

```
~/.claude/plugins/cache/prismantis/prismantis/0.12.0/hooks/register.tsx
```

Line 172, inside the `AssistantMessage` handler.

**Before:**
```tsx
<Box flexDirection="row">
```

**After:**
```tsx
<Box flexDirection="row" {...(e.props.isFirstOfReply ? { marginTop: 1 } : {})}>
```

**Why.** Prismantis draws a reply with no top margin, so it sits flush against the user's prompt or the last tool row. Its existing `rowGap={1}` only spaces blocks *within* a reply.

**Important.** The `isFirstOfReply` gate is load-bearing. That handler runs once per block, so an ungated `marginTop` double-spaces the entire message.

### Re-applying after an update

```bash
# find the new version directories
ls ~/.claude/plugins/cache/hellosverre-mods/skins/
ls ~/.claude/plugins/cache/prismantis/prismantis/

# check whether the patches survived
grep -c "LOCAL PATCH" \
  ~/.claude/plugins/cache/hellosverre-mods/skins/*/hooks/register.tsx \
  ~/.claude/plugins/cache/prismantis/prismantis/*/hooks/register.tsx

# after re-applying
/reload-plugins
```

Both patches carry a `LOCAL PATCH (jyeh4, 2026-10-12)` comment explaining the reasoning, so grepping for that string finds them.

---

## Current configuration

### prismantis

Set via `/config`. Stored in `~/.claude/settings.json` under `pluginConfigs`.

| Setting | Value | Why |
|---|---|---|
| `enabled` | true | |
| `theme` | tokyo-night | Matches Ghostty |
| `headingStyle` | banner | The thing that solves the original problem |
| `tableStyle` | box | |
| `promptStyle` | **off** | User prefers skins' prompt, which has a margin |
| `toolStyle` | classic | |
| `toolRows` | **false** | Hands tool rows to skins. Resolves a conflict. |
| `highlightNumbers` | **false** | Was colouring every digit mid-sentence, read as noise |
| `highlightPaths` | true | |
| `copyButtons` | false | User disliked them |
| `diagramHints` | **false** | See the warning below |
| `mermaid` | true | |

> **Do not turn `diagramHints` back on without asking.**
> It silently appends roughly 190 tokens to every message the user sends, instructing the model to add diagrams and charts. Those copies accumulate in conversation history, so a 100-turn session carries about 19,000 tokens of the same repeated paragraph. It also pushes toward longer replies, which works directly against the goal of this whole project.

### skins

Set via `/skin`, **not** `/config`. Skins has no `userConfig` block in its manifest, so it does not appear in `/config` at all. Stored in `~/.claude/plugins/store/skins_hellosverre-mods-*.json`.

| Setting | Value |
|---|---|
| `skin` | tokyo-night |
| `rail` | on |
| `tables` | on (**should probably be off**, see conflicts) |
| `shimmer` | on |
| `band` | off |
| `clipOutput` | off |

Commands: `/skin`, `/skin list`, `/skin gallery`, `/skin <name>`, `/skin off`, `/skin pin`. Toggles take an explicit value: `/skin tables off`.

### Claude Code

| Setting | Value |
|---|---|
| `verbose` | true |

### Ghostty

```
~/dotfiles/ghostty/config.ghostty   (symlinked into ~/Library/Application Support/com.mitchellh.ghostty/)
```

```
bold-color = #e0af68
font-style-bold = ExtraBold
font-thicken = true
adjust-cell-height = 12%
```

`bold-color` replaced `bold-is-bright = true`, which did nothing. The bright variant only applies to text that already has a colour, and Claude Code draws bold on the default foreground, so there was no bright version to switch to. Naming an explicit colour is the form that works.

This file is in git, so `git diff ghostty/` shows the change and `git checkout ghostty/` reverts it.

**Unverified:** the user has never confirmed the amber bold is actually visible. Worth checking.

**Also note:** `font-family = "JetBrainsMono Nerd Font Mono"` is set but **the font is not installed**. Ghostty silently falls back to SF Mono, which has notoriously weak bold. `font-style-bold = ExtraBold` is therefore inert. Installing the font would improve things further.

---

## Known conflicts

Both mods register handlers for the same UI components. The handlers are middleware: each either draws or calls `next()` to pass down the chain. Whichever loads first wraps the other, and load order is not controllable.

| Surface | prismantis | skins | Status |
|---|---|---|---|
| Tool rows | off | draws | resolved |
| Tool groups | off | patched to pass through | resolved |
| Prompts | off | draws | resolved |
| Tool output | — | draws | clean |
| Question dialog | — | draws | clean |
| Context band | — | off | clean |
| Command output | draws | — | clean |
| **Replies** | draws | draws when a table or fence is present | **contested** |
| **Duration line** | draws | draws | **unresolvable** |

**Replies** is fixable with `/skin tables off`. The user prefers prismantis tables.

**Duration line** cannot be fixed. Prismantis registers it without a `next` parameter at all:

```tsx
on('ui.render', { component: 'TurnDuration' }, ($, e) => renderTurnDuration(...))
```

It draws unconditionally and ends the chain. Skins does the same from its side. Neither has a toggle. Whichever loads first wins permanently. The only visible consequence is whether the duration line carries skins' tool count and lines-changed stats.

### The asymmetry worth knowing

- prismantis **can** step back from tool rows (`toolRows: false`), **cannot** step back from tables (no on/off, only `tableStyle`).
- skins **can** step back from tables (`/skin tables off`), **cannot** step back from tool rows (only `/skin off` entirely).

So "prismantis does prose, skins does furniture" is the only workable division. The reverse is impossible.

---

## Rendering facts established by testing

Tested directly on this machine, not read from docs.

**Carries colour:** emoji, links, inline code spans, syntax highlighting in a fenced block, `diff` fences.

**Does not carry colour, without a mod:** GitHub alert blocks (`> [!NOTE]`), plain blockquotes, bold, italic, heading text, body text.

**Other:**
- Markdown `---` renders as three literal dashes, not a rule. A literal run of box-drawing characters (`━` U+2501, `─` U+2500) renders as a real continuous line.
- A terminal has one font size. Heading hierarchy is impossible without a mod; this is a hard constraint, not a missing feature.
- `maxProseWidth` **does not exist** as a Claude Code setting, despite appearing in some search results. The settings schema rejects it. Pane width is the only lever.
- `MessageDisplay` hooks can only replace displayed text, not add colour.
- Custom themes in `~/.claude/themes/` colour UI chrome only. There is no heading token.

---

## The writing-style work: status

Three layers. Fixing one does nothing for the other two.

| Layer | Decides | Status |
|---|---|---|
| Scope | How much gets said | **Not written** |
| Structure | How it's arranged | Drafted, five rules |
| Sentences | How each line reads | Drafted, four rules |

None of it has been written to a file yet. The intended destination is `~/.claude/writing-style.md`, imported from `~/.claude/CLAUDE.md` with `@~/.claude/writing-style.md`. That import syntax is verified to work at user scope, with tilde expansion and no approval prompt.

### Structure, drafted

1. Open with a summary that stands completely alone. **Assume it is the only part read word for word, because it is.** Put in it: the answer, anything that changes what the user would do, and any caveat that would change their mind. Leave out evidence, reasoning and alternatives. The test is not "did I cover everything" but "if they stop here, have they been misled". Two to four sentences, written plainly rather than compressed.
2. A heavy rule under the summary.
3. A map table naming the sections and what is in each.
4. Each section gets a bold title with a light rule under it.
5. Caveats last, **except** any caveat that would change the answer, which goes in the summary.

Rules 2, 3 and 4 exist because the renderer could not show hierarchy. With prismantis on they are closer to decoration, and with it off they are load-bearing. The user currently wants them.

### Sentences, drafted

1. Every sentence must be complete at its full stop. If a term stays open until a later sentence resolves it, split it in two.
2. Say what literally happens. Not "misdirects", "conflates", "surfaces".
3. Bullet leads and table cells are full sentences with a subject and a verb. Headings stay short noun phrases.
4. Never use em dashes. Already in the user's global CLAUDE.md.

Deliberately four. An audit concluded eleven rules get followed worse than four.

### Scope, not written

Three candidate rules, none agreed:

- Match response size to question size.
- Answer what was asked. No pre-empted follow-ups or unused alternatives.
- Lead with the answer; detail only if it changes what the user would do.

The second needs a carve-out for correctness and safety caveats. The user works on BFS banking services and vulnerability patching, where a suppressed caveat is expensive.

---

## Open items

- [ ] Write the three layers into `~/.claude/writing-style.md` and import it from `CLAUDE.md`
- [ ] Draft the scope layer, the only one with nothing written
- [ ] Run `/skin tables off` to resolve the last fixable conflict
- [ ] Verify patch 2 actually renders correctly; it has not been visually confirmed
- [ ] Verify Ghostty `bold-color` is taking effect
- [ ] Consider installing JetBrains Mono Nerd Font, currently referenced but absent
- [ ] Report the skins single-call collapse upstream; it is a clean bug report
- [ ] Decide whether to re-enable skins' context band (`/skin band on`)

---

## User context for a cold agent

- Works at Macquarie on BFS Spring Boot services. Vulnerability patching and Spring Boot upgrades are the day job.
- Corporate-managed Mac with **Santa binary allowlisting**. Unapproved native binaries are killed with exit 137. `glow` is installed but blocked. Node, Python and browsers are fine. No Homebrew. Mods are fine because they run inside Claude Code's existing Node process.
- Mid-transition to a fully keyboard-driven setup: Ghostty, tmux, nvim. Beginner across that stack but moving fast.
- Thinks out loud, often via voice transcription. The important point is frequently mid-sentence rather than up front. Read to the end.
- Responds well to being told when he is right, and to being shown a tradeoff rather than handed a verdict. He has repeatedly chosen the option that was not recommended, with good reasons.
- **Wants errors owned plainly.** Several claims were wrong during this work and flagging each one directly moved things forward.
