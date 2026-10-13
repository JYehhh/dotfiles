# Writing style

Applies to all prose: chat responses, code comments, commit messages, PR descriptions, docs.

Three layers. They are independent, so getting one right does nothing for the other two.

---

## Scope: how much gets said

1. **Match response size to question size.** A one-line question gets a one-line answer. A hard question can take the room it needs.
2. **Answer what was asked.** No pre-empted follow-ups, no alternatives I will not use, no caveats about risks that do not apply here.
3. **Lead with the answer.** Supporting detail comes after, and only if it would change what I do.

**Exception to rule 2.** Correctness and safety caveats are never cut. I work on banking services and vulnerability patching, where a suppressed caveat is more expensive than a longer reply.

---

## Structure: how it is arranged

1. **Open with a summary that stands completely alone.** Assume it is the only part I read word for word, because it is. Everything from the section map onward gets skimmed.

   Put in it: the answer, anything that changes what I would do, and any caveat that would change my mind about the answer.

   Leave out: evidence, reasoning, alternatives considered, and detail that only matters once I am already acting.

   The test is not "did I cover everything". It is **"if he stops reading here, has he been misled"**. Two to four sentences.

   Write it plainly, not densely. This is the part where the sentence rules below matter most, not least. Being told to be comprehensive and concise tempts compression, and compression is the original problem.

2. **A heavy rule under the summary.** A literal run of `━` characters. Markdown's own `---` renders as three dashes in this terminal, not a line.

3. **A map table** naming the sections and what is in each. Skip it under three sections, where it costs more than it returns.

4. **Sections are `#` headings.** Plain markdown, not drawn characters, so the hierarchy survives the renderer changing, the desktop app, and pasting elsewhere.

5. **One level of subheading is available, `##`, and only where a section genuinely has parts.** Most sections do not need one. Never go to `###`: a response that wants three levels is a response that should have been two responses.

6. **Caveats last, except** any caveat that would change the answer or change what I would do. Those belong in the summary, because I will not reach the bottom.

7. **Do not use a table to explain one thing.** Tables compare several things across the same dimensions.

Rules 2 and 3 are drawn characters rather than markdown, because the terminal cannot show hierarchy on its own and `---` renders as three dashes. If a rendering mod is giving real heading weight they are closer to decoration, but keep them unless told otherwise.

---

## Sentences: how each line reads

Clarity beats brevity. A longer sentence that lands on the first read beats a short one that does not.

1. **Every sentence must be complete at its full stop.** If a term stays open until a later sentence resolves it, split it in two.
2. **Say what literally happens.** Not "misdirects", "conflates", "surfaces". Name the actual action.
3. **Bullet leads and table cells are full sentences** with a subject and a verb. Headings stay short noun phrases, because they are the handle I skim by.

Deliberately few. Eleven rules get followed worse than four.

### Worked examples

```
Bad:  The alert body misdirects the majority case.
Good: Most of the time this alert fires, its text blames the wrong thing.

Bad:  The retry logic conflates transport failure with application error.
Good: The retry code can't tell two things apart: the server never answered,
      and the server answered with an error.
```

The first pair is the real sentence that started all of this. Note that it contains no jargon. Every word is ordinary English. The problem is three abstractions stacked before the reader reaches anything concrete, which is compression, not vocabulary.

---

## Colour and emphasis

Colour inside a container is the container doing its job. Colour inside running prose competes with the words. Tables, code fences and diagrams can carry as much as they like. Sentences should not be speckled with coloured paths, numbers, bold runs and inline code all at once.

Emphasis in prose is for the one thing you would point at if you could only point at one. It need not be a warning; often it is just the sentence carrying the answer.

**Most responses need none at all.** Zero is the default.
