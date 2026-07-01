-- Minimal neovim config.
-- Goal: match the WezTerm rose-pine-moon theme and let WezTerm's
-- transparency/blur show through, instead of nvim painting a solid bg.

vim.opt.termguicolors = true   -- 24-bit "true color"; rose-pine's palette needs it
vim.opt.number = true          -- line numbers (like the screenshot)

-- Leader key: the "prefix" pressed before a shortcut. Space, by convention.
-- Must be set before any <leader> mapping below.
vim.g.mapleader = " "

-- rose-pine lives in pack/colors/start/, so it's already on the runtimepath
-- by the time this file runs -- no plugin manager needed.
require("rose-pine").setup({
  variant = "moon",            -- "moon" == the rose-pine-moon flavor
  styles = {
    transparency = true,       -- DON'T paint Normal's background ->
                               -- WezTerm's 0.8 opacity + blur shows through
  },
})

vim.cmd.colorscheme("rose-pine-moon")

-- Telescope: fuzzy finder. Lives in pack/plugins/start/, so it (and its
-- plenary.nvim dependency) are already on the runtimepath by now.
require("telescope").setup({})

-- Fuzzy-finder keymaps:
--   <leader>f  == Space then f  -> find files by name
--   <leader>s  == Space then s  -> search file *contents* (live grep, uses ripgrep)
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Telescope: find files" })
vim.keymap.set("n", "<leader>s", builtin.live_grep,  { desc = "Telescope: search in files" })

-- Fugitive: Git inside Neovim. <leader>g opens the git status window
-- (stage with `s`, unstage with `u`, commit with `cc`). Also `:Git blame`, `:Git log`.
vim.keymap.set("n", "<leader>g", "<cmd>Git<cr>", { desc = "Fugitive: git status" })

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
