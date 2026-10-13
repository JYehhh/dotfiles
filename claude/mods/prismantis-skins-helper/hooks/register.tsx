import type { Register } from 'claude-code'

/**
 * prismantis-skins-helper
 *
 * Four behaviours that used to be hand-edits inside prismantis and skins. Those
 * reverted silently on every plugin update, because plugins install into
 * version-numbered folders and the patched file was left behind in the old one.
 *
 * The whole design rests on one property of the hook chain: `next(e)` runs the
 * plugins beneath and resolves to whatever they drew. So this mod never competes
 * for the draw. It asks the others to draw, then wraps the result. That is why it
 * keeps working when prismantis and skins change their internals: it does not know
 * or care what they produce, only that they produce something.
 *
 * See README.md next to this file for the original goals, which is the thing to
 * read if the behaviour below ever stops matching what was wanted.
 */
export const register: Register = (on, options) => {
  // A blank line above the start of a reply.
  //
  // Prismantis draws a reply as a row Box with no top margin, so it sits flush
  // against the prompt or the last tool row. Gated on isFirstOfReply because the
  // handler runs once per block, and wrapping every block double-spaces the whole
  // message.
  if (options.replyGap !== false) {
    on('ui.render', { component: 'AssistantMessage' }, async ($, e, next) => {
      const theirs = await next(e)
      if (!e.props.isFirstOfReply) return theirs
      const { Box } = $.ui.resolve(e)

      return <Box marginTop={1}>{theirs}</Box>
    })
  }

  // A blank line above the "Cooked for 12s" line.
  //
  // Both prismantis and skins draw this one, and neither calls next, so whichever
  // loads first wins. It does not matter which: either way the drawn element comes
  // back here and gets wrapped.
  if (options.durationGap !== false) {
    on('ui.render', { component: 'TurnDuration' }, async ($, e, next) => {
      const theirs = await next(e)
      const { Box } = $.ui.resolve(e)

      return <Box marginTop={1}>{theirs}</Box>
    })
  }

  // A blank line above the working spinner.
  //
  // The spinner is replaced by the duration line when a turn ends. Both carry the
  // same margin on purpose, so the transcript does not jump by a line at that
  // moment.
  if (options.spinnerGap !== false) {
    on('ui.render', { component: 'Spinner' }, async ($, e, next) => {
      const theirs = await next(e)
      const { Box } = $.ui.resolve(e)

      return <Box marginTop={1}>{theirs}</Box>
    })
  }

  // Never collapse a batch of tool calls into a tally.
  //
  // This one cannot be done by wrapping, because the goal is to stop another mod
  // drawing rather than to decorate what it drew. Instead of fighting for the draw,
  // rewrite the event: both prismantis and skins check `isExpanded` and step back
  // when it is true, so claiming the group is already expanded makes them hand it
  // to Claude Code's own renderer, which draws every call.
  //
  // This is the one behaviour here that depends on load order. It only works while
  // this mod sits above the others in the chain. If batches start collapsing again,
  // that is the first thing to check, not a bug in the condition.
  if (options.expandToolGroups !== false) {
    on('ui.render', { component: 'ToolGroup' }, (_$, e, next) =>
      next({ ...e, props: { ...e.props, isExpanded: true } }))
  }
}
