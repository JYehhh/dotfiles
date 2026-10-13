# The four original hand-patches, verbatim

Applied 2026-10-12, reverted the same day once `prismantis-skins-helper` replaced them.

Kept because the mod is the *current* way to achieve these goals, not the only way. If prismantis or skins change enough that the mod's wrapping approach stops working, these show exactly what was edited and what the original upstream code looked like, so a direct patch can be re-applied as a fallback.

The goals themselves, which matter more than either implementation, are in
`~/.claude/dev-mods/<session-id>/prismantis-skins-helper/README.md`.

**Versions these were written against:** skins `0.1.1`, prismantis `0.12.0`.
Line numbers will drift. Match on the surrounding code, not the line.

---

## Patch 1: skins never collapses tool groups

**File:** `~/.claude/plugins/cache/hellosverre-mods/skins/0.1.1/hooks/register.tsx`
**Around line:** 445

### Upstream original

```tsx
  on('ui.render', { component: 'ToolGroup' }, async ($, e, next) => {
    const active = await activeSkin($)

    if (active === null || e.props.isExpanded) {
      return next(e)
    }

    return groupRow(lookOf($.ui.resolve(e), active, e.surface), e.props.calls)
  })
```

### Patched version

```tsx
  // LOCAL PATCH (jyeh4, 2026-10-12): skins no longer collapses tool groups at all,
  // so every call draws as its own row however many ran together. The original
  // replaced an unexpanded batch with a tally like "Run 1", which hid the command.
  //
  // To revert, restore the body:
  //   const active = await activeSkin($)
  //   if (active === null || e.props.isExpanded) return next(e)
  //   return groupRow(lookOf($.ui.resolve(e), active, e.surface), e.props.calls)
  //
  // `groupRow` is now an unused import from './rows', which is harmless.
  on('ui.render', { component: 'ToolGroup' }, async (_$, e, next) => next(e))
```

**Note.** An earlier, narrower version of this patch only passed through when the group held a single call, which fixed the `Run 1` case while keeping real batches collapsed:

```tsx
    if (active === null || e.props.isExpanded || e.props.calls.length === 1) {
```

That narrower form is the one worth reporting upstream, because collapsing a group of one loses the command and saves no space. The user then asked for nothing to collapse at all, which produced the full pass-through above.

---

## Patch 2: a blank line above each reply

**File:** `~/.claude/plugins/cache/prismantis/prismantis/0.12.0/hooks/register.tsx`
**Around line:** 166, inside the `AssistantMessage` handler

### Upstream original

```tsx
    return (
      <Box flexDirection="row">
        <Box width={2} flexShrink={0}>
          <Text color={style.theme.accent}>{e.props.isFirstOfReply ? '●' : ' '}</Text>
        </Box>
```

### Patched version

```tsx
    return (
      // LOCAL PATCH (jyeh4, 2026-10-12): a blank line above the start of a reply, so
      // it is not flush against the prompt or the last tool row. The existing
      // rowGap={1} only spaces blocks within a reply, not the reply itself.
      // Gated on isFirstOfReply, because this handler runs per block and an
      // ungated marginTop would double-space the whole message.
      // Revert by removing the marginTop spread below.
      <Box flexDirection="row" {...(e.props.isFirstOfReply ? { marginTop: 1 } : {})}>
        <Box width={2} flexShrink={0}>
          <Text color={style.theme.accent}>{e.props.isFirstOfReply ? '●' : ' '}</Text>
        </Box>
```

**The `isFirstOfReply` gate is load-bearing.** The handler runs once per block, so an ungated `marginTop` double-spaces the entire message.

---

## Patch 3: a blank line above the duration line

**File:** `~/.claude/plugins/cache/prismantis/prismantis/0.12.0/hooks/render.tsx`
**Around line:** 729

### Upstream original

```tsx
export const renderTurnDuration = ({ Text }: ElementTable, style: Style, word: string, durationMs: number): RenderElement => (
  <Text color={style.theme.codeComment}>
    {`✻ ${word} for `}
    <Text color={style.theme.number}>{formatDuration(durationMs)}</Text>
  </Text>
)
```

### Patched version

```tsx
// LOCAL PATCH (jyeh4, 2026-10-12): a blank line above the duration line, so it is
// not flush against the last paragraph of the reply. Text cannot carry a margin in
// Ink, so the line is wrapped in a Box. Revert by removing the Box and restoring
// the destructure to { Text }.
export const renderTurnDuration = ({ Box, Text }: ElementTable, style: Style, word: string, durationMs: number): RenderElement => (
  <Box marginTop={1}>
    <Text color={style.theme.codeComment}>
      {`✻ ${word} for `}
      <Text color={style.theme.number}>{formatDuration(durationMs)}</Text>
    </Text>
  </Box>
)
```

**Note the destructure change**, `{ Text }` to `{ Box, Text }`. Ink's `Text` cannot carry a margin, so a `Box` has to be introduced.

---

## Patch 4: a blank line above the spinner

**File:** `~/.claude/plugins/cache/hellosverre-mods/skins/0.1.1/hooks/rows.tsx`
**Around line:** 404 and 430, two edits in one function

### Upstream original

```tsx
export function spinnerRow(look: Look, word: string, frame: number, elapsedMs: number) {
  const { Text } = look.ui
  const { palette } = look.skin
```

```tsx
  return (
    <Text>
      <Text color={palette.user}>{`${look.icons.frames[frame % look.icons.frames.length] ?? ''} `}</Text>
      {runs.map(run => (
        <Text color={run.color}>{run.text}</Text>
      ))}
      <Text color={palette.muted}>{`…  ${formatDuration(elapsedMs)}`}</Text>
    </Text>
  )
}
```

### Patched version

```tsx
// LOCAL PATCH (jyeh4, 2026-10-12): Box + marginTop added so the spinner is not flush
// against the reply or the last tool row. Revert by restoring `const { Text }` and
// removing the wrapping Box at the end of this function.
export function spinnerRow(look: Look, word: string, frame: number, elapsedMs: number) {
  const { Box, Text } = look.ui
  const { palette } = look.skin
```

```tsx
  return (
    <Box marginTop={1}>
      <Text>
        <Text color={palette.user}>{`${look.icons.frames[frame % look.icons.frames.length] ?? ''} `}</Text>
        {runs.map(run => (
          <Text color={run.color}>{run.text}</Text>
        ))}
        <Text color={palette.muted}>{`…  ${formatDuration(elapsedMs)}`}</Text>
      </Text>
    </Box>
  )
}
```

**Patches 3 and 4 must use the same margin.** The spinner is replaced by the duration line when a turn ends, so if they differ the transcript jumps by a line at that moment.

---

## Why these were abandoned

Plugins install into version-numbered directories. A patched file is left behind in the old directory on every update and silently stops being loaded. Nothing warns you. The symptom is the old behaviour quietly returning, weeks later, with no obvious cause.

A mod is not affected by that, which is why `prismantis-skins-helper` exists.

## Finding them again if they were ever re-applied

```bash
grep -rn "LOCAL PATCH" \
  ~/.claude/plugins/cache/hellosverre-mods/skins/*/hooks/ \
  ~/.claude/plugins/cache/prismantis/prismantis/*/hooks/
```
