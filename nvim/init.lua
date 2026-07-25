-- Minimal neovim config.
-- Goal: match the WezTerm rose-pine-moon theme and let WezTerm's
-- transparency/blur show through, instead of nvim painting a solid bg.

vim.opt.termguicolors = true   -- 24-bit "true color"; rose-pine's palette needs it
vim.opt.number = true          -- line numbers (like the screenshot)
vim.opt.relativenumber = true  -- + relative distances -> current line shows its
                               -- real number, others show how far away they are
                               -- (so `5k`/`3j`, and `d5j`/`y3k`, need no counting)

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

-- which-key: after you press a prefix (like <leader> == Space) and PAUSE, a
-- popup lists every key you can press next and what it does. Great for learning
-- your own mappings -- it auto-reads the `desc = "..."` labels on the keymaps
-- further down. Pure Lua, no extra binaries.
require("which-key").setup()

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
    lualine_b = { "branch", "diff" },                       -- pure git: branch + this file's +/~/- vs HEAD
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

-- noice.nvim: replaces the command line, messages and search UI. The `:` cmdline
-- and `/` search move to a floating box mid-screen; messages route to popups;
-- LSP hover/signature get proper markdown rendering. Needs nui.nvim.
-- Treesitter note: noice wants parsers for full cmdline highlighting. You have
-- vim/lua/markdown/markdown_inline bundled with nvim 0.12, but `regex` and
-- `bash` are missing -- `:checkhealth noice` will flag them. It still works
-- without them (you just lose `/`-search-pattern and terminal highlighting);
-- adding them needs nvim-treesitter, which Santa blocks on your work machine.
require("noice").setup({
  lsp = {
    -- render LSP hover / signature docs as real markdown (you have the parsers)
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
    },
  },
  presets = {
    command_palette = true,        -- cmdline + completion menu grouped together
    long_message_to_split = true,  -- send long :messages to a split, not a modal
    lsp_doc_border = true,         -- bordered hover/signature popups
  },
  -- snacks.notifier (enabled below) owns vim.notify and renders the toasts, so
  -- tell noice NOT to also grab vim.notify -- otherwise the two fight over who
  -- draws notifications. noice still owns the cmdline, search and :messages.
  notify = { enabled = false },
})

-- Fugitive: Git inside Neovim. <leader>g opens the git status window
-- (stage with `s`, unstage with `u`, commit with `cc`). Also `:Git blame`, `:Git log`.
vim.keymap.set("n", "<leader>g", "<cmd>Git<cr>", { desc = "Fugitive: git status" })

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
  -- messages, and your own vim.notify() calls, land here as toasts. (noice is
  -- told above not to fight it for vim.notify.) <leader>n opens the history.
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

-- Turn the three servers on.
vim.lsp.enable({ "lua_ls", "pyright", "clangd" })

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
