# Vim & tmux Cheat Sheet

## Contents  (search a name to jump -- `/` in vim/less, Ctrl-F in a browser)
- Command structure
- File Navigation
- Tabs
- MOTIONS  --  Horizontal / Word / Vertical / Find a character / Scrolling / Search & jump
- TEXT OBJECTS  --  word / quotes / parens / braces / brackets / tag / paragraph
- OPERATORS  --  Core operators / Doubled / Handy combos
- BUFFER STATE  --  Save / Reload / Close / Swap files
- OIL  --  file explorer: browse & edit the filesystem as a buffer
- LSP  --  code intelligence: definitions, references, docs, diagnostics

## Command structure (how the keystrokes combine)

    ["reg]   [count]   operator   [count]   {motion | text-object}

Each slot, left to right:
- `["reg]`               which register (clipboard) to use          [optional]
- `[count]`              how many times / how much                  [optional]
- `operator`             the action to perform
- `[count]`              multiply the motion that follows           [optional]
- `motion/text-object`   what to act on, or where to move the cursor

- Doubling the operator (`dd`, `yy`, `cc`) = act on the whole line.
- Visual mode reverses the order: select first, then press the operator.

## File Navigation (moving between files)
- `Space f`      find files by name        (Telescope)
- `Space s`      search text in project    (Telescope live grep)
- `:e <path>`    open a file               (Tab to autocomplete the path)
- `Ctrl-o`       jump BACK to where you were (across files too)
- `Ctrl-i`       jump FORWARD again
- `:ls`          list open buffers (files)
- `:b <name>`    switch to a buffer by name (Tab completes)
- `:bd`          close current file/buffer (Neovim stays open)
- `Space g`      (tmux) pop up this cheat sheet

## Tabs (separate workspaces/layouts, each holding its own splits)
- `:tabnew`          open a new empty tab
- `:tabnew <path>`   open a file in a new tab
- `:tabedit <path>`  same as above (Tab completes the path)
- `gt`               go to NEXT tab
- `gT`               go to PREVIOUS tab
- `2gt`              jump to tab number 2
- `:tabclose`        close the current tab
- `:tabonly`         close all OTHER tabs
- `:tabs`            list all open tabs and their windows
- `:tabmove 0`       move current tab to the front (or `+1` / `-1` to nudge)



# ═══════════════════════════  MOTIONS  ═══════════════════════════
# A "motion" moves the cursor. On its own it just navigates -- but pair it
# with an operator (d=delete, c=change, y=yank) and it acts on the range it
# covers.  e.g.  dw = delete word,  d$ = delete to end of line,  y} = yank
# to next paragraph.  Add a count to multiply:  3w,  d2j,  5G.

## Horizontal (within a line)
- `h` / `l`      left / right one character
- `0`            first column (very start of line)
- `^`            first NON-blank character
- `$`            end of line
- `g_`           last non-blank character
- `20|`          jump to column 20

## Word motions
- `w` / `W`      start of next word / WORD   (WORD = whitespace-delimited)
- `e` / `E`      end of word / WORD (this word from start/mid; else next)
- `b` / `B`      start of previous word / WORD
- `ge` / `gE`    end of previous word / WORD

## Vertical (between lines)
- `j` / `k`      down / up one line
- `gg` / `G`     first / last line of file
- `42G`          jump to line 42   (or `:42`)
- `{` / `}`      previous / next paragraph   (blank-line delimited)
- `(` / `)`      previous / next sentence
- `+` / `-`      first non-blank of next / previous line
- `H` / `M` / `L`  top / middle / bottom of the visible screen

## Find a character on the current line
- `f<char>`      jump forward ONTO next <char>
- `F<char>`      jump backward onto previous <char>
- `t<char>`      jump forward TILL just before <char>
- `T<char>`      jump backward till just after <char>
- `;` / `,`      repeat last f/F/t/T  forward / backward

## Scrolling (move the view; H/M/L reposition the cursor)
- `Ctrl-d` / `Ctrl-u`   half page down / up
- `Ctrl-f` / `Ctrl-b`   full page down / up
- `Ctrl-e` / `Ctrl-y`   scroll one line down / up (cursor stays put)
- `zz` / `zt` / `zb`    center / top / bottom the current line on screen

## Search & jump
- `/text` / `?text`   search forward / backward for "text"
- `n` / `N`           next / previous search match
- `*` / `#`           next / previous instance of the word under the cursor
- `%`                 jump to matching bracket  ( ) [ ] { }
- `` `` ``            jump back to your previous position
- `ma`  then  `` `a ``  set mark "a", then jump back to it later


# ═════════════════════════  TEXT OBJECTS  ════════════════════════
# A text object is the OTHER kind of noun (not a motion): it selects a whole
# REGION regardless of cursor position. It does NOTHING on its own -- only
# after an operator (diw, ci") or in visual mode (viw).
#   i = "inner"  (contents only)      a = "around" (includes delimiters/space)

## Handy text objects   (use as  d / c / y / v  +  object)
- `iw` / `aw`    inner word / a word   (aw includes the trailing space)
- `i"` / `a"`    inside / around double quotes
- `i(` / `a(`    inside / around parentheses   (also `ib` / `ab`)
- `i{` / `a{`    inside / around braces        (also `iB` / `aB`)
- `i[` / `a[`    inside / around square brackets
- `it` / `at`    inside / around an HTML/XML tag
- `ip` / `ap`    inner / a paragraph


# ══════════════════════════  OPERATORS  ══════════════════════════
# An operator is a VERB -- it acts on a range given by a motion or text object.
# Pattern:  operator + motion/text-object.  Double the letter to act on the
# whole line (dd, yy, cc).  Add a count to multiply (3dd, d2w).

## Core operators
- `d`            delete (cut -- goes to a register, paste back with `p`)
- `c`            change (delete, then drop into insert mode)
- `y`            yank (copy)
- `p` / `P`      paste after / before the cursor
- `>` / `<`      indent right / left
- `=`            auto-indent / reformat
- `gu` / `gU`    lowercase / UPPERCASE
- `g~`           toggle case
- `gq`           reformat / wrap text
- `!`            filter the range through an external shell command

## Doubled = act on the whole current line
- `dd`           delete the line
- `yy`           yank the line
- `cc`           change the line
- `>>` / `<<`    indent the line right / left

## Handy combos (operator + motion / text-object)
- `dw`           delete to next word
- `d$`  (or `D`) delete to end of line
- `ciw`          change inner word (whole word, anywhere in it)
- `ci"`          change inside quotes
- `dap`          delete a paragraph
- `yi(`          yank inside parentheses
- `>ip`          indent this paragraph
- `guiw`         lowercase the current word


# ════════════════════════  BUFFER STATE  ═════════════════════════
# A "buffer" is the in-memory copy of a file you edit. "Disk" is what's saved.
# These manage the gap between the two -- especially when something else (like
# Claude) edits the file on disk while you have it open.

## Save  (buffer -> disk)
- `:w`            write (save) the current buffer to disk
- `:wa`           write ALL modified buffers
- `:x`  or  `ZZ`  save (only if changed) and quit
- `:w <path>`     save a copy to another path

## Reload / refresh  (disk -> buffer)
- `:e`            reload the file from disk (warns if you have unsaved edits)
- `:e!`           FORCE reload, discarding your unsaved changes
- `:checktime`    check if the file changed on disk; reload if `autoread` is on

## Close / discard
- `:bd`           close the buffer (Neovim stays open)
- `:bd!`          close the buffer, discarding unsaved changes
- `:q` / `:q!`    close window / quit   (`!` = discard unsaved changes)
- `:qa!`          quit ALL windows, discard everything

## Swap files  (the crash-recovery journal for unsaved edits)
- Warning "swap file already exists" = file is open elsewhere OR a session crashed
- `(A)bort` / `(Q)uit`   back out -- go use the window that already has it open
- `(O)pen Read-Only`     just view it, no editing
- `(R)ecover`            restore unsaved work AFTER a real crash
- `(D)elete`             remove a STALE swap (only if no other nvim still has it)
- `:recover`             recover from a swap manually  (or `nvim -r <file>`)


# ═════════════════════════════  OIL  ═════════════════════════════
# Oil = file explorer that lets you browse & EDIT the filesystem as a buffer.
- `-`            open the PARENT directory in oil (press again to go up more)
- `Space e`      open oil in a floating window
- `<CR>`         enter a directory / open the file under the cursor
- `<C-p>`        preview the file/dir under the cursor
- `<C-c>`        close oil

## File operations  (edit the buffer, then `:w` to apply)
- `new line`     create a file  (end the name with `/` = a directory)
- `edit a name`  rename the file
- `dd`           delete  (`dd` then `p` in another dir = move)


# ═════════════════════════════  LSP  ═════════════════════════════
# LSP = language "smarts": go-to-definition, references, docs, diagnostics.
- `gd`           go to definition
- `gr`           find references
- `K`            hover docs for symbol
- `[d` / `]d`    previous / next error (diagnostic)
- `Space rn`     rename symbol
- `Space ca`     code action (quick fixes)


