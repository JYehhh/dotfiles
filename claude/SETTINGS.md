# Claude Code and terminal settings

Everything that makes this setup look and behave the way it does, in one place. Most of it travels automatically with the files in this folder. The sections marked **manual** do not, and have to be set again by hand on a new machine.

Last updated 2026-10-13.

---

## What lives where

| File in this folder | Links to | Holds |
|---|---|---|
| `settings.json` | `~/.claude/settings.json` | Model, verbose, hooks, permissions, plugin list, prismantis options |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | Global instructions. Imports `writing-style.md`. |
| `writing-style.md` | `~/.claude/writing-style.md` | Scope, structure and sentence rules |
| `statusline-command.sh` | `~/.claude/statusline-command.sh` | Fallback status line, where gsd isn't installed |
| `mods/` | (a plugin marketplace) | `prismantis-skins-helper`, the one mod written here |
| `fixing-verbosity/` | (docs only) | Why all of this exists, and the original patches verbatim |

---

## Plugins

Declared in `settings.json`, so Claude Code installs them by itself on first launch.

| Plugin | Marketplace | Job |
|---|---|---|
| `prismantis@prismantis` | `NahumLitvin/prismantis` (GitHub) | Colours prose: headings, tables, code, links, diagrams |
| `skins@hellosverre-mods` | `hellosverre/claude-skins` (GitHub) | Styles furniture: tool rows, spinner, prompt |
| `prismantis-skins-helper@jyeh4-mods` | `~/dotfiles/claude/mods` (local) | Spacing around elements, never collapse tool groups |

The two third-party mods are named, not copied. Their source is never edited. Anything custom goes in `prismantis-skins-helper` instead, so updates to the other two cannot erase it.

---

## Prismantis options

Stored in `settings.json` under `pluginConfigs`, so they travel. Change them with `/config`.

| Setting | Value | Why |
|---|---|---|
| `theme` | `tokyo-night` | Matches Ghostty |
| `headingStyle` | `banner` | `#` gets a box, `##` gets an underline |
| `tableStyle` | `box` | |
| `promptStyle` | `off` | Skins draws the prompt, with a margin |
| `toolStyle` | `classic` | |
| `toolRows` | `false` | Hands tool rows to skins |
| `highlightNumbers` | `false` | Was colouring every digit mid-sentence |
| `copyButtons` | `false` | |
| `diagramHints` | `false` | **Keep off.** Adds ~190 hidden tokens to every prompt asking for more diagrams. |

---

## Skins options (manual)

Skins stores these in `~/.claude/plugins/store/`, not in `settings.json`, so they **do not travel**. Run these once on a new machine:

```
/skin tokyo-night
/skin tables off
/skin rail on
/skin shimmer on
/skin band off
/skin clip off
```

`tables off` matters most: it stops skins fighting prismantis over every reply that has a table in it.

---

## prismantis-skins-helper options

In `/config` under the mod. All default to on, which is what's wanted.

| Setting | Does |
|---|---|
| `replyGap` | Blank line above each reply |
| `durationGap` | Blank line above the "Worked for 1m" line |
| `spinnerGap` | Blank line above the working spinner |
| `expandToolGroups` | Every tool call gets its own row, never a "Run 3" tally |

---

## Claude Code settings

In `settings.json`, so they travel.

| Setting | Value |
|---|---|
| `verbose` | `true` |
| `model` | `opus` |

**Model, manual on a work machine.** Macquarie's managed settings at `/Library/Application Support/ClaudeCode/managed-settings.json` pin new sessions to `sonnet` and beat `settings.json`. Opus is on the allowed list, so the `claude` function in `~/.zshrc` passes `--model opus` on every launch. That function is not in this repo yet.

---

## Ghostty

In `../ghostty/config.ghostty`, already linked by `install.sh`.

```
font-family = "JetBrainsMono Nerd Font Mono"
bold-color = #e0af68
font-style-bold = ExtraBold
adjust-cell-height = 12%
```

`bold-color` makes Claude Code's bold headings amber. `bold-is-bright` does not work for this, because Claude Code draws bold on the default foreground colour, which has no bright variant.

## Font (manual)

JetBrains Mono Nerd Font is not part of macOS and there is no Homebrew on the work machine:

```bash
curl -fL -o /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o /tmp/JetBrainsMono.zip -d ~/Library/Fonts
```

Then fully quit and reopen Ghostty. Without the font, Ghostty silently falls back to SF Mono and `ExtraBold` does nothing.

---

## Linking it all up

Lines to add to `install.sh`, alongside the existing tmux, nvim and Ghostty links:

```bash
echo "==> Linking Claude Code config"
mkdir -p "$HOME/.claude"
ln -sf "$DOTFILES/claude/settings.json"    "$HOME/.claude/settings.json"
ln -sf "$DOTFILES/claude/CLAUDE.md"        "$HOME/.claude/CLAUDE.md"
ln -sf "$DOTFILES/claude/writing-style.md" "$HOME/.claude/writing-style.md"
```

**Watch out with `settings.json`.** `/config` and `/plugin` rewrite that file. If a rewrite replaces the file instead of editing it in place, the symlink breaks and changes stop reaching the repo. Check `ls -l ~/.claude/settings.json` still shows an arrow after changing a setting.

`settings.json` is portable across machines and usernames:

- Hooks use `$HOME` and find `node` on the PATH, and each one is skipped when its script is missing. So the gsd hooks run on the work machine and do nothing on one without `~/.claude/hooks`. They are written as `[ ! -f "$f" ] || node "$f"` so a guard's exit code 2 (block) still gets through. `... && node "$f" || true` would swallow it.
- The status line uses gsd's when it is installed, and `statusline-command.sh` from this folder otherwise.
- The `jyeh4-mods` marketplace path is `~/dotfiles/claude/mods`. Claude Code expands the `~` into its own `~/.claude/plugins/known_marketplaces.json` at session start and leaves `settings.json` untouched. Tested 2026-10-14 on 2.1.296.

Each machine's own copy of the gsd hooks still has to be installed there. They are not in this repo.

---

## Per-machine changes

The personal machine is the base. Its changes are committed and pushed, and every other machine pulls them.

The work machine can't push, so anything only it wants (claude-nine, its Daily Diary section in `CLAUDE.md`, a plugin switched off) lives there as one local commit that is never pushed. Update it with:

```bash
git pull --rebase
```

The rebase replays the local commit on top of whatever came in. A plain `git pull` would leave a merge commit, and uncommitted edits block the pull entirely. If both sides changed the same lines of `settings.json`, fix the conflict once and `git rebase --continue`.
