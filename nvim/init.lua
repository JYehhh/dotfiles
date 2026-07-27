-- Minimal neovim config.
-- Goal: match the WezTerm rose-pine-moon theme and let WezTerm's
-- transparency/blur show through, instead of nvim painting a solid bg.

vim.opt.termguicolors = true   -- 24-bit "true color"; rose-pine's palette needs it
vim.opt.number = true          -- line numbers (like the screenshot)
vim.opt.relativenumber = true  -- + relative distances -> current line shows its
                               -- real number, others show how far away they are
                               -- (so `5k`/`3j`, and `d5j`/`y3k`, need no counting)

-- Sign column: ALWAYS visible. The default ("auto") only draws the column when
-- something occupies it, so the moment gitsigns adds a hunk marker or clangd
-- adds an error sign, every line of text jumps one column sideways -- and jumps
-- back when it clears. Pinning it open costs one column and kills the jitter.
vim.opt.signcolumn = "yes"

-- How long the cursor must sit still (ms) before CursorHold fires. Neovim's
-- default is 4000 -- far too slow for gitsigns' inline blame, which hangs off
-- that event. 300ms feels immediate without thrashing.
vim.opt.updatetime = 300

-- Leader key: the "prefix" pressed before a shortcut. Space, by convention.
-- Must be set before any <leader> mapping below.
vim.g.mapleader = " "

-- Completion menu behaviour (used by the built-in LSP autocomplete below):
--   menu     = show the popup menu of suggestions
--   menuone  = show it even when there's only ONE match
--   noselect = DON'T auto-highlight the first item -- wait for me to pick one
--   noinsert = DON'T insert any text until I confirm with <C-y>
-- Together, noselect+noinsert mean the menu is a pure suggestion: nothing lands
-- in the buffer (and <Esc> stays safe) until you deliberately accept.
vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }

-- Indentation: SPACES, 4 wide. Neovim's default is an 8-column tab -- that's
-- the "too much tabbage" you saw next to VSCode's 4.
--   expandtab   -> the Tab key inserts spaces, not a literal tab character
--   shiftwidth  -> width of one indent level (autoindent, >>, and `{`<CR>)
--   tabstop     -> how many columns a literal tab renders as
--   softtabstop -> how far Tab / Backspace move in insert mode
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- jk / kj to escape -- a home-row alternative to reaching for <Esc>.
-- INSERT MODE ONLY, on purpose: in visual mode j/k are movement keys, and in
-- command mode they're just text you're typing, so mapping either there would
-- break more than it helps. (You also already have Caps->Ctrl, so Caps+[ = Esc.)
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape insert mode" })
vim.keymap.set("i", "kj", "<Esc>", { desc = "Escape insert mode" })
-- Shorter mapping timeout so the brief wait after a trailing "j" isn't annoying.
-- Also shortens the which-key popup delay and the window for leader chords --
-- 300ms is a common balance; raise it if <leader> sequences start feeling rushed.
vim.opt.timeoutlen = 300

-- System clipboard, on demand. Vim's registers are SEPARATE from the macOS
-- clipboard by default, which is deliberate: `d`, `c` and `x` are yanks too, so
-- syncing everything (clipboard = "unnamedplus") means every `dd` overwrites
-- whatever you copied from your browser. These maps cross the boundary only
-- when you ask.  `"+y` reads as: into register `+` (the system clipboard), yank.
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y',  { desc = "Yank to system clipboard" })
vim.keymap.set("n",          "<leader>Y", '"+Y',  { desc = "Yank line to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p',  { desc = "Paste from system clipboard" })

-- which-key: after you press a prefix (like <leader> == Space) and PAUSE, a
-- popup lists every key you can press next and what it does. Great for learning
-- your own mappings -- it auto-reads the `desc = "..."` labels on the keymaps
-- further down. Pure Lua, no extra binaries.
require("which-key").setup()

-- nvim-autopairs: type `{` and get `{}` with the cursor between; typing the
-- closing `}` when it's already there just steps over it; backspacing the open
-- bracket deletes both. With map_cr (on by default), pressing <CR> inside a
-- pair expands it into an indented block -- so in C++ `{` then <Enter> gives:
--     {
--         |          <- cursor here, indented
--     }
-- (the middle-line indent comes from Neovim's built-in C/C++ indentation).
-- Pure Lua, no binaries. Your native LSP completion uses <C-y> to accept, not
-- <CR>, so autopairs owning <CR> doesn't clash with it.
require("nvim-autopairs").setup({})

-- tokyonight lives in pack/colors/start/, so it's already on the runtimepath
-- by the time this file runs -- no plugin manager needed. (rose-pine and
-- catppuccin are installed too; swap them in via :colorscheme to compare.)
require("tokyonight").setup({
  style = "storm",                  -- the default tokyonight variant (blue-tinged)
  transparent = false,              -- paint a SOLID base (#24283b) --
                                    -- no see-through, no desktop bleeding in
})

vim.cmd.colorscheme("tokyonight-storm")

-- Telescope: fuzzy finder. Lives in pack/plugins/start/, so it (and its
-- plenary.nvim dependency) are already on the runtimepath by now.
require("telescope").setup({
  defaults = {
    file_ignore_patterns = { "^.git/" },
  },
  pickers = {
    find_files = {
      hidden = true,
    },
  },
})

-- Fuzzy-finder keymaps:
--   <leader>f  == Space then f  -> find files by name
--   <leader>s  == Space then s  -> search file *contents* (live grep, uses ripgrep)
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Telescope: find files" })
vim.keymap.set("n", "<leader>s", builtin.live_grep,  { desc = "Telescope: search in files" })

-- oil.nvim: browse & EDIT the filesystem as a normal buffer. Inside oil:
--   <CR>  enter a directory / open a file      `-`    go UP one directory
--   <C-p> preview the file under the cursor    <C-c>  close oil
-- Do file ops by EDITING the buffer (add a line = new file, change text =
-- rename, `dd` = delete) then `:w` to apply. Pure Lua, no external binary.
require("oil").setup({
  default_file_explorer = true,           -- open directories in oil (not netrw)
  view_options = { show_hidden = true },  -- show dotfiles (handy in a dotfiles repo)
})

-- `-` opens the PARENT directory in oil, on demand. (This overrides the
-- rarely-used "first non-blank of previous line" motion -- a common oil trade.)
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil: open parent directory" })
-- <leader>e floats the explorer center-screen -- the on-demand "pull it up" pop.
vim.keymap.set("n", "<leader>e", "<cmd>Oil --float<cr>", { desc = "Oil: float file explorer" })

-- flash.nvim: jump anywhere ON SCREEN by typing a couple of characters. As you
-- type, every match gets a one-letter LABEL next to it -- press that letter and
-- the cursor teleports there. It's `/search` without leaving your place or
-- hitting `n` repeatedly. Pure Lua, no binaries (works fine under Santa).
--   s{char}{char}  -> start a flash jump, then press a shown label to land
-- It also SUPERCHARGES the keys you already know: f/t/F/T get labels too, so a
-- second `;` is replaced by "just press the label of the one you want".
-- NOTE: this overrides native `s` (= "substitute char", i.e. `cl`). That's the
-- standard flash trade and rarely missed -- `cl` still does the same thing.
require("flash").setup({})
vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end,
  { desc = "Flash: jump to any on-screen match" })

-- bufferline.nvim: shows every open BUFFER as a styled tab across the top, so
-- you can SEE what you have open instead of guessing. (Buffers are invisible by
-- default -- which is why you can :bd a few times and be surprised how many
-- were still open.) Picks up the devicons + tokyonight colours automatically.
-- Stock default styling.
require("bufferline").setup({})

-- Recolour just the active-tab accent line ("the blue line") -> storm green.
-- Both tokyonight and bufferline set BufferLineIndicatorSelected on the
-- ColorScheme event, so re-apply it there to make sure ours lands last.
local function green_indicator()
  vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", { fg = "#9ece6a" })
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = green_indicator })
green_indicator()

-- Move along the bar in the ORDER SHOWN (not by buffer id). Mirrors your
-- [d/]d diagnostic jumps. Native H/L (screen top/bottom) are left untouched.
vim.keymap.set("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Buffer: previous" })
vim.keymap.set("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Buffer: next" })

-- <leader>1..9 -> jump straight to the Nth tab on the bar (the ordinal number).
for i = 1, 9 do
  vim.keymap.set("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>",
    { desc = "Buffer: go to " .. i })
end

-- <leader>bd -> close THIS buffer (and its bar entry). Close them one at a time
-- and watch the count shrink -- the fix for the "how many did I have open?" pile-up.
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Buffer: delete current" })

-- lualine.nvim: the statusline at the BOTTOM of the window (bufferline is the
-- top). The default statusline shows filename + position via an ugly printf
-- format string; lualine gives you configurable SEGMENTS instead. Uses your
-- devicons for the filetype glyph. Since it draws the mode itself, we turn off
-- the built-in "-- INSERT --" text with showmode below.
--   theme = "auto"  -> derive colours from the active colorscheme (tokyonight)
--   globalstatus    -> ONE statusline for the whole window, not one per split
-- Layout is six segments: a b c on the left, x y z on the right.
vim.opt.showmode = false

-- nvim-navic: an LSP-driven "breadcrumb" of where the cursor is in the code
-- (e.g. Position › is_attacked). auto_attach hooks into any LSP that provides
-- document symbols -- clangd/pyright/lua_ls all do -- so your LspAttach block
-- needs no change. Pure Lua, no compile (Santa-safe). Feeds lualine_c below.
require("nvim-navic").setup({
  lsp = { auto_attach = true },
  separator = " › ",
  highlight = true,
})

require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = true,
    section_separators = { left = "", right = "" },   -- straight edges
    component_separators = { left = "|", right = "|" },
  },
  -- All six sub-sections are set EXPLICITLY on purpose: lualine deep-merges
  -- with 'keep', so any section you OMIT silently reverts to its default --
  -- which is how "progress" kept reappearing. Empty {} is the only real drop.
  sections = {
    lualine_a = { "mode" },                                 -- NORMAL / INSERT / ...
    -- Pure git: branch + this file's +/~/- vs HEAD. `source` points the diff
    -- counts at gitsigns' already-computed hunks instead of lualine shelling out
    -- to `git diff` on a timer -- same numbers, no subprocess, and it can never
    -- disagree with the signs in the gutter.
    lualine_b = {
      "branch",
      { "diff", source = function()
          local gs = vim.b.gitsigns_status_dict
          return gs and { added = gs.added, modified = gs.changed, removed = gs.removed } or nil
        end },
    },
    lualine_c = {
      { "filename", path = 1 },                             -- path = 1 -> relative path
      -- navic breadcrumb -- left-aligned by the filename because it reads as a
      -- path. Shows only when the LSP can supply document symbols.
      {
        function() return require("nvim-navic").get_location() end,
        cond = function()
          return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
        end,
      },
    },
    lualine_x = {
      -- Diagnostic MESSAGE for the line under the cursor -- the actual warning/
      -- error text, so you can read it without a jump or a float. Sits left of
      -- the count so it expands leftward without shoving anything. Coloured by
      -- severity (red = error, yellow = warn). (Neovim's built-in search count
      -- stays on the command line; lualine's searchcount was removed to free this.)
      {
        function()
          local d = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })[1]
          return d and d.message or ""
        end,
        cond = function()
          return #vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 }) > 0
        end,
        fmt = function(s) return s:sub(1, 60) end,   -- truncate long messages
        color = function()
          local d = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })[1]
          local by_sev = { "#f7768e", "#e0af68", "#7dcfff", "#7dcfff" }  -- err/warn/info/hint
          return d and { fg = by_sev[d.severity] } or nil
        end,
      },
      -- Diagnostic COUNTS (clangd's ⚠/✗ totals), next to the server that makes them.
      "diagnostics",
      -- Attached LSP servers -- anchored in the corner, ALWAYS shown.
      {
        function()
          local names = vim.tbl_map(function(c) return c.name end,
            vim.lsp.get_clients({ bufnr = 0 }))
          return #names > 0 and (" " .. table.concat(names, " ")) or ""
        end,
      },
    },
    lualine_y = {},                                         -- progress dropped
    lualine_z = {},                                         -- location dropped
  },
  -- extensions: swap in a sensible statusline for SPECIAL buffers, so the bar
  -- doesn't show a meaningless "oil:///..." or "fugitive:///..." path.
  --   oil      -> shows the current directory when you're in the file explorer
  --   fugitive -> shows git context in the :Git status window
  --   quickfix -> labels the quickfix / location list window
  extensions = { "oil", "fugitive", "quickfix" },
})

-- nvim-hlslens: shows the search count as VIRTUAL TEXT right at the match --
-- [3/12] travels with you as you press n/N, instead of living in the corner.
-- This is the one thing noice was kept for; hlslens does only this, so the
-- cmdline, messages and errors all stay native and bottom-anchored.
require("hlslens").setup({
  calm_down = true,       -- clear the highlights once the cursor leaves a match
  nearest_only = true,    -- only float the count for the NEAREST match, not all
})

-- Route the search keys through hlslens so it can redraw the counter.
local hls = { noremap = true, silent = true }
vim.keymap.set("n", "n",
  [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]], hls)
vim.keymap.set("n", "N",
  [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]], hls)
vim.keymap.set("n", "*",  [[*<Cmd>lua require('hlslens').start()<CR>]],  hls)
vim.keymap.set("n", "#",  [[#<Cmd>lua require('hlslens').start()<CR>]],  hls)
vim.keymap.set("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], hls)
vim.keymap.set("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], hls)

-- lsp_signature: the parameter-hint popup while you're typing a call, e.g.
-- `is_attacked(` shows (Square sq, Colour by). Neovim has the LSP request built
-- in (vim.lsp.buf.signature_help) but does NOT auto-trigger it; this does.
-- It auto-closes when you leave insert mode or move off the call -- and
-- <C-k> in insert mode toggles it off if it's ever in the way.
require("lsp_signature").setup({
  hint_enable = false,        -- no inline virtual-text hint; just the popup
  floating_window = true,
  toggle_key = "<C-k>",       -- insert-mode toggle
  handler_opts = { border = "rounded" },
})

-- Fugitive: Git inside Neovim. <leader>g opens the git status window
-- (stage with `s`, unstage with `u`, commit with `cc`). Also `:Git blame`, `:Git log`.
vim.keymap.set("n", "<leader>g", "<cmd>Git<cr>", { desc = "Fugitive: git status" })

-- gitsigns: the VSCode gutter. Coloured marks in the sign column showing which
-- lines you've added / changed / deleted RELATIVE TO HEAD (not relative to the
-- remote -- it clears the moment you commit, even though you've just moved
-- further from origin). Fugitive above is the DELIBERATE half of git (sit down,
-- read the whole diff, commit); gitsigns is the AMBIENT half -- always-on
-- peripheral awareness plus hunk-level surgery without leaving the buffer.
require("gitsigns").setup({
  signs = {
    add          = { text = "│" },   -- solid bar: these lines are new
    change       = { text = "│" },
    delete       = { text = "_" },   -- something was removed BELOW this line
    topdelete    = { text = "‾" },   -- removed ABOVE the first line
    changedelete = { text = "~" },   -- changed AND had lines removed
    untracked    = { text = "┆" },   -- dashed: file isn't in git at all yet
  },
  -- Virtual text at the end of the current line: "Jyeh, 2 hours ago - fix eval".
  -- OFF by default because it's noisy while you type; <leader>hb toggles it on
  -- for when you're reading unfamiliar code and want continuous authorship.
  current_line_blame = false,
  current_line_blame_opts = { delay = 300, virt_text_pos = "eol" },

  -- Keymaps are declared HERE rather than at the top level because gitsigns
  -- attaches per-buffer -- these only exist in buffers that are actually inside
  -- a git repo, so `]c` still does its native thing everywhere else.
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local function map(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
    end

    -- NAVIGATION. ]c / [c are vim's built-in "next/prev change in diff mode";
    -- gitsigns reuses the same keys outside diff mode, which is why they feel
    -- native. This is the underrated half: your own edits become an index you
    -- can tab through after coming back to a file cold.
    map("n", "]c", function() gs.nav_hunk("next") end, "Next git hunk")
    map("n", "[c", function() gs.nav_hunk("prev") end, "Previous git hunk")

    -- INSPECT.
    map("n", "<leader>hp", gs.preview_hunk,      "Preview hunk (float)")
    map("n", "<leader>hd", gs.diffthis,          "Diff this file vs index")
    map("n", "<leader>hD", function() gs.diffthis("~") end, "Diff this file vs HEAD~")
    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
    map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle inline blame")

    -- STAGE / RESET. The real payoff: stage ONE hunk out of a messy file so
    -- atomic commits stop being a chore (this is `git add -p` without the TUI).
    -- In visual mode the same keys act on exactly the lines you've selected --
    -- finer than a hunk. <leader>hu undoes the last stage; <leader>hr throws
    -- the hunk away entirely (destructive -- it reverts to HEAD).
    map("n", "<leader>hs", gs.stage_hunk,  "Stage hunk")
    map("n", "<leader>hr", gs.reset_hunk,  "Reset hunk (discard)")
    map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selected lines")
    map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selected lines")
    map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
    map("n", "<leader>hS", gs.stage_buffer, "Stage whole buffer")

    -- TEXT OBJECT: `ih` = "inner hunk". So `dih` deletes the hunk under the
    -- cursor, `vih` selects it, `yih` yanks it. Works like `iw`/`ip`.
    map({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
  end,
})

-- Gutter colours, straight from the TokyoNight Storm palette. gitsigns' own
-- defaults link to the colourscheme's diff groups, which in Storm come out
-- as three similar washed-out shades -- hard to read at a glance. These are
-- the saturated palette colours instead, so the three states are distinct in
-- peripheral vision without having to look directly at the column.
--
-- This has to run on ColorScheme, not just once: tokyonight DEFINES the
-- GitSigns* groups when it loads, so anything set beforehand gets clobbered
-- (the same trap as BufferLineIndicatorSelected further up).
local function gitsigns_colors()
  local hl = {
    GitSignsAdd          = "#9ece6a",  -- green  -- new lines
    GitSignsChange       = "#7aa2f7",  -- blue   -- modified lines
    GitSignsDelete       = "#f7768e",  -- red    -- lines removed below
    GitSignsTopdelete    = "#f7768e",  -- red    -- lines removed above line 1
    GitSignsChangedelete = "#ff9e64",  -- orange -- changed AND shrank: its own state
    GitSignsUntracked    = "#565f89",  -- grey   -- not in git yet; deliberately quiet
  }
  for group, fg in pairs(hl) do
    vim.api.nvim_set_hl(0, group, { fg = fg })
  end
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = gitsigns_colors })
gitsigns_colors()

-- Claude Code: bridges THIS Neovim to the `claude` CLI (same protocol the
-- official VS Code / JetBrains extensions use). Claude's edits arrive as a
-- DIFF inside the editor -- accept/reject in nvim -- instead of being written
-- to disk behind your back. Needs snacks.nvim (the terminal it opens in) and
-- the `claude` CLI on your PATH (install via npm so it rides the `node` binary).
-- snacks.nvim is a COLLECTION of ~25 small modules, and every one of them is
-- OFF until you name it here -- which is why installing it appeared to do
-- nothing. It's in plugins.txt because claudecode needs its popup terminal.
require("snacks").setup({
  -- notifier: stacked, coloured, auto-dismissing toast notifications in the
  -- top-right, with history. Takes over vim.notify -- so every plugin's
  -- messages, and your own vim.notify() calls, land here as toasts.
  -- <leader>n opens the history.
  notifier = { enabled = true, timeout = 3000 },

  -- scroll: animate the viewport instead of teleporting it. Applies to
  -- <C-u>/<C-d>, <C-f>/<C-b>, zz/zt/zb, gg/G, and search jumps (n/N) -- so
  -- your eye tracks where the text went rather than re-finding its place.
  -- Mouse-wheel scrolling is deliberately left un-animated.
  --   step  = ms PER LINE scrolled -- so short jumps are quick, long ones
  --           take longer. This is the main speed knob.
  --   total = a CEILING on the whole animation, not its duration. Stops
  --           gg->G in a huge file from animating for a minute.
  -- Plugin defaults are step=10, total=200. Below is deliberately snappier.
  -- easing: 41 functions available (see :lua =require("snacks.animate.easing")).
  --   "linear"  = constant speed (the stock choice, and what's set here)
  --   "outQuad" = starts fast, decelerates in -- reads as "arriving"
  scroll = {
    animate = { duration = { step = 5, total = 100 }, easing = "linear" },
    -- Scroll again within 100ms and it switches to THIS instead -- which is
    -- why holding <C-d> already felt faster than a single press.
    animate_repeat = { delay = 100, duration = { step = 3, total = 40 } },
  },
})

-- <leader>n -> re-open recent notifications (they auto-dismiss; this brings
-- back the history in a scrollable float).
vim.keymap.set("n", "<leader>n", function() require("snacks").notifier.show_history() end,
  { desc = "Notifications: history" })

require("claudecode").setup({})   -- defaults: connects to `claude` found on PATH

--   <leader>a  == Space then a  -> toggle the Claude Code session
vim.keymap.set("n", "<leader>a", "<cmd>ClaudeCode<cr>", { desc = "Claude Code: toggle" })
--   in visual mode, <leader>a sends the selected lines to Claude as context
vim.keymap.set("v", "<leader>a", "<cmd>ClaudeCodeSend<cr>", { desc = "Claude Code: send selection" })

-- ---------------------------------------------------------------------------
-- LSP: language "smarts" (autocomplete, errors, go-to-definition).
-- Uses Neovim 0.11+'s BUILT-IN LSP client -- no plugin needed. Each server is
-- a separate program (installed on PATH) that Neovim talks to per language.
-- ---------------------------------------------------------------------------

-- Lua  (server: lua-language-server) -- knows about the `vim` global so it
-- won't warn about it while editing this config.
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".git" },
  settings = { Lua = { diagnostics = { globals = { "vim" } } } },
})

-- Python  (server: pyright)
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
})

-- C / C++  (server: clangd, from Xcode)
vim.lsp.config("clangd", {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_markers = { "compile_commands.json", ".clangd", ".git" },
})

-- Java  (server: jdtls, the Eclipse JDT Language Server)
-- Unlike the three above there's no binary to install: jdtls is a pile of JARs
-- that install.sh unpacks into ~/.local/share/jdtls, launched by `java -jar`.
-- We invoke the launcher JAR directly rather than jdtls' own wrapper script --
-- one less moving part, and it keeps `java` (already approved) the only
-- executable in the chain, so Santa has no new binary to judge.
local jdtls_home = vim.env.JDTLS_HOME or (vim.env.HOME .. "/.local/share/jdtls")

-- The launcher JAR has a version-stamped filename that changes every release,
-- so glob for it instead of hardcoding. Equinox also needs a platform config
-- directory; jdtls ships one per OS/arch and picking the wrong one fails at
-- startup with an unhelpful OSGi error.
local jdtls_launcher = vim.fn.glob(jdtls_home .. "/plugins/org.eclipse.equinox.launcher_*.jar", true, true)[1]
local jdtls_config = (function()
  local arm = vim.uv.os_uname().machine == "arm64"
  for _, dir in ipairs(arm and { "config_mac_arm", "config_mac" } or { "config_mac" }) do
    if vim.fn.isdirectory(jdtls_home .. "/" .. dir) == 1 then return jdtls_home .. "/" .. dir end
  end
end)()

-- ROOT DETECTION. Load-bearing for Java, because the marker files aren't
-- unique to the project root the way compile_commands.json is.
--
-- THE NORMAL CASE HERE is microservices: a plain parent folder with each
-- service cloned into it, one pom.xml per service, and each one indexed in
-- ISOLATION. Two things keep the walk inside a single service -- it stops at
-- the git root (each clone has its own .git), and it stops at the first
-- directory with no pom.xml, which the parent folder is. So a service never
-- absorbs its siblings even if the parent folder isn't a repo at all.
--
-- The outermost-pom walk below is for the OTHER Maven layout: a multi-module
-- build (an aggregator pom with <modules>, as in a layered monolith or a
-- library shipping several artifacts) where EVERY module has its own pom.
-- There, "nearest ancestor with a pom.xml" finds the module you're in rather
-- than the aggregator above it -- jdtls sees one module, treats its siblings
-- as unresolved external jars, and cross-module `gr`/`gd` quietly return
-- wrong answers. Walking up while the pom chain stays contiguous fixes it.
--
-- Note <parent> in a pom is NOT this: that's inheritance from an artifact
-- resolved out of Nexus/Central (spring-boot-starter-parent, a corporate
-- parent), not a directory. Only <modules> means dirs on disk.
--
-- Gradle needs none of this: settings.gradle exists only at the root.
local function java_root(fname)
  local start = vim.fs.dirname(fname)
  local git_root = vim.fs.dirname(vim.fs.find(".git", { path = start, upward = true })[1] or "")

  local gradle = vim.fs.find({ "settings.gradle", "settings.gradle.kts" }, { path = start, upward = true })[1]
  if gradle then return vim.fs.dirname(gradle) end

  local outermost = nil
  local dir = start
  while dir and dir ~= "/" do
    if vim.fn.filereadable(dir .. "/pom.xml") == 1 then
      outermost = dir
    elseif outermost then
      break                        -- chain broke: the last pom we saw is the root
    end
    if dir == git_root then break end   -- never climb out of the repo
    dir = vim.fs.dirname(dir)
  end
  return outermost or (git_root ~= "" and git_root or nil)
end

vim.lsp.config("jdtls", {
  filetypes = { "java" },
  -- Neovim calls root_dir as (bufnr, on_dir) and expects the answer via the
  -- callback -- NOT as a return value, and NOT given a filename. Calling on_dir
  -- is also what activates the client at all: skip it and the server silently
  -- never starts. java_root() above stays a plain fname->path function so it
  -- can be reasoned about (and tested) on its own; this just adapts it.
  root_dir = function(bufnr, on_dir)
    on_dir(java_root(vim.api.nvim_buf_get_name(bufnr)))
  end,
  cmd = function(dispatchers, config)
    -- -data is jdtls' per-project index. It lives OUTSIDE the project (keyed by
    -- root path) because it's hundreds of MB of churning Eclipse state -- so
    -- there's nothing to gitignore, and two projects can't corrupt each other.
    local root = config.root_dir or vim.fn.getcwd()
    local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(root, ":p:h:t")

    -- jdtls itself needs a JDK 21+ to RUN. That is INDEPENDENT of what your
    -- projects target -- a 21 JVM happily builds a Java 17 project. If the
    -- `java` on PATH is older, point JAVA_HOME_FOR_JDTLS at a 21 JDK.
    local java = vim.env.JAVA_HOME_FOR_JDTLS
      and (vim.env.JAVA_HOME_FOR_JDTLS .. "/bin/java") or "java"

    return vim.lsp.rpc.start({
      java,
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.level=WARNING",
      "-Xmx2G",                                   -- jdtls is memory-hungry on big repos
      "--add-modules=ALL-SYSTEM",
      "--add-opens", "java.base/java.util=ALL-UNNAMED",
      "--add-opens", "java.base/java.lang=ALL-UNNAMED",
      "-jar", jdtls_launcher,
      "-configuration", jdtls_config,
      "-data", workspace,
    }, dispatchers)
  end,
  settings = {
    java = {
      configuration = {
        -- THE ONE MACHINE-SPECIFIC KNOB. These names are Eclipse execution
        -- environment IDs and must match exactly ("JavaSE-21", not "21").
        -- jdtls picks per project from what the build file declares and falls
        -- back to `default`. Fill in the real paths at work --
        -- `/usr/libexec/java_home -V` lists what's installed.
        runtimes = {
          -- { name = "JavaSE-21", path = "/path/to/jdk-21", default = true },
          -- { name = "JavaSE-17", path = "/path/to/jdk-17" },
        },
      },
      -- Keep imports tidy without a plugin: sort, and don't collapse to `.*`.
      completion = { importOrder = { "java", "javax", "com", "org" } },
      sources = { organizeImports = { starThreshold = 99, staticStarThreshold = 99 } },
      format = { enabled = true },
    },
  },
})

-- Turn the servers on. jdtls only if it's actually unpacked on this machine --
-- otherwise opening a .java file would throw on every buffer. This is what
-- lets the same init.lua ride to a machine that hasn't run install.sh yet.
vim.lsp.enable({ "lua_ls", "pyright", "clangd" })
if jdtls_launcher and jdtls_config then
  vim.lsp.enable({ "jdtls" })
end

-- When a server attaches to a buffer, wire up the useful keymaps + autocomplete.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition,    opts)  -- go to definition
    vim.keymap.set("n", "gr", vim.lsp.buf.references,     opts)  -- find references
    vim.keymap.set("n", "K",  vim.lsp.buf.hover,          opts)  -- docs popup
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)  -- rename symbol
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- fixes/actions
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev,  opts)  -- prev error
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next,  opts)  -- next error

    -- Auto-completion as you type (built-in; press <C-y> to accept a suggestion).
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
  end,
})
