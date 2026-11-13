vim.g.mapleader = " "

-- Options
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.swapfile = false
opt.undofile = true
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.termguicolors = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.completeopt = "menuone,noinsert,popup,fuzzy"
vim.g.netrw_bufsettings = "noma nomod nu nobl nowrap ro rnu"
-- No remote plugins in Node/Python/Perl/Ruby (everything is Lua): skip those providers
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Keymaps
local map = vim.keymap.set
map("n", "<Leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<Leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<Leader>e", "<cmd>Ex<CR>", { desc = "File explorer" })
map({ "n", "x" }, "<Leader>y", '"+y', { desc = "Yank to clipboard" })
map({ "n", "x" }, "<Leader>p", '"+p', { desc = "Paste from clipboard" })
map({ "n", "x" }, "<Leader>F", function() require("conform").format({ async = true }) end, { desc = "Format" })

-- Plugins
-- Rebuild treesitter parsers whenever nvim-treesitter is installed or updated
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    if ev.data.spec.name == "nvim-treesitter" and ev.data.kind ~= "delete" then
      if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
      vim.cmd("TSUpdate")
    end
  end,
})
vim.pack.add({
  "https://github.com/vague2k/vague.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/stevearc/conform.nvim",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  "https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/ibhagwan/fzf-lua",
})
require("vague").setup({ transparent = true })
vim.cmd.colorscheme("vague")
require("conform").setup({
  -- oxfmt: Prettier-compatible; a project's own node_modules copy wins over the global one
  formatters_by_ft = {
    python = { "ruff_format" },
    javascript = { "oxfmt" }, typescript = { "oxfmt" }, javascriptreact = { "oxfmt" }, typescriptreact = { "oxfmt" },
    vue = { "oxfmt" }, json = { "oxfmt" }, jsonc = { "oxfmt" }, html = { "oxfmt" }, yaml = { "oxfmt" }, css = { "oxfmt" },
  },
  default_format_opts = { lsp_format = "fallback" },
})

-- Fuzzy finder, using skim (sk) via fzf-lua's "skim" profile; setup({}) switches back to fzf. :FzfLua lists every picker
local fzf = require("fzf-lua")
fzf.setup({ "skim" })
map("n", "<Leader>f", fzf.files, { desc = "Find files" })
map("n", "<Leader>g", fzf.live_grep, { desc = "Grep project" })
map("n", "<Leader>*", fzf.grep_cword, { desc = "Grep word under cursor" })
map("n", "<Leader>b", fzf.buffers, { desc = "Open buffers" })
map("n", "<Leader>s", fzf.git_status, { desc = "Git status" })
map("n", "<Leader>r", fzf.resume, { desc = "Resume last search" })
map("n", "<Leader>k", fzf.keymaps, { desc = "Search keymaps" })
map("n", "<Leader>d", fzf.diagnostics_workspace, { desc = "Diagnostics (project)" })
map("n", "<Leader>S", fzf.lsp_live_workspace_symbols, { desc = "Symbols (project)" })
-- LSP lists in fzf-lua instead of quickfix; grn, grt, grx, K stay Neovim's defaults
map("n", "grr", fzf.lsp_references, { desc = "References" })
map("n", "gri", fzf.lsp_implementations, { desc = "Implementations" })
map("n", "gO", fzf.lsp_document_symbols, { desc = "Symbols (file)" })
map("n", "gd", fzf.lsp_definitions, { desc = "Definitions" })
map({ "n", "x" }, "gra", fzf.lsp_code_actions, { desc = "Code actions" })
map("x", "<Leader>*", fzf.grep_visual, { desc = "Grep selection" })
map("n", "<Leader>o", fzf.oldfiles, { desc = "Recent files" })
map("n", "<Leader>h", fzf.help_tags, { desc = "Help" })
map("n", "<Leader>/", fzf.blines, { desc = "Lines in file" })
map("n", "<Leader>c", fzf.git_hunks, { desc = "Git changes (hunks)" })
map("n", "<Leader>l", fzf.git_bcommits, { desc = "Git log (file)" })
map("n", "<Leader>B", fzf.git_branches, { desc = "Git branches" })
map("n", "<Leader>L", fzf.git_commits, { desc = "Git log (project)" })
map("n", "<Leader>D", fzf.diagnostics_document, { desc = "Diagnostics (file)" })
map("n", "<Leader>m", fzf.marks, { desc = "Marks" })
map("n", '<Leader>"', fzf.registers, { desc = "Registers" })
map("n", "<Leader>j", fzf.jumps, { desc = "Jumps" })
map("n", "<Leader>u", fzf.undotree, { desc = "Undo tree" })
map("n", "<Leader>Q", fzf.quickfix, { desc = "Quickfix list" })
map("n", "<Leader>:", fzf.commands, { desc = "Commands" })

-- Treesitter (lua, vim, vimdoc, markdown, c and query parsers ship with nvim)
require("nvim-treesitter").install({ "typescript", "tsx", "javascript", "json", "bash", "python", "vue", "yaml", "html", "css", "jinja", "jinja_inline" })
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args) pcall(vim.treesitter.start, args.buf) end,
})

-- LSP: servers live in ~/.local/bin (npm --prefix ~/.local, uv tool); configs come from nvim-lspconfig
-- TS/JS: tsc (TypeScript 7, native Go, `tsc --lsp`). Python: pyrefly (Rust) + ruff
-- Vue: vue_ls handles HTML/CSS in .vue files, vtsls (.vue only) handles their TypeScript through the Vue plugin
-- ponytail: vtsls stays until Vue Language Tools v4 supports TypeScript 7, then .vue moves to tsc too
vim.lsp.config("vtsls", {
  settings = { vtsls = { tsserver = { globalPlugins = { {
    name = "@vue/typescript-plugin",
    location = vim.fn.expand("~/.local/lib/node_modules/@vue/language-server"),
    languages = { "vue" },
    configNamespace = "typescript",
  } } } } },
  filetypes = { "vue" },
})
-- pyrefly: without a project config it uses the "basic" preset (few errors); "default" = Pyrefly's normal checks.
-- A project's pyrefly.toml / [tool.pyrefly] still wins
vim.lsp.config("pyrefly", { settings = { python = { pyrefly = { typeCheckingMode = "default" } } } })
-- Jinja templates use their own extension so .html stays plain HTML (Frappe templates stay .html)
vim.filetype.add({ extension = { jinja = "jinja", jinja2 = "jinja", j2 = "jinja" } })
-- .html: superhtml (Zig) does HTML; vscode-html only does CSS in <style> (its HTML suggestions + hover off).
-- .jinja: jinja_lsp (Rust) does the template parts; html_jinja = vscode-html with HTML suggestions on
vim.lsp.config("html_jinja", vim.tbl_deep_extend("force", vim.lsp.config.html, { filetypes = { "jinja" } }))
vim.lsp.config("html", { filetypes = { "html" }, settings = { html = { suggest = { html5 = false } } } })
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "html" then client.server_capabilities.hoverProvider = false end
  end,
})
vim.lsp.config("emmet_language_server", { filetypes = { "html", "jinja", "css", "javascriptreact", "typescriptreact", "vue" } })
vim.lsp.enable({ "lua_ls", "pyrefly", "ruff", "tsc", "vtsls", "vue_ls", "jsonls", "yamlls",
  "superhtml", "html", "cssls", "jinja_lsp", "html_jinja", "emmet_language_server" })
vim.diagnostic.config({ virtual_text = true })

-- Completion: Ctrl-Space shows LSP suggestions, Ctrl-Y accepts, Ctrl-E closes
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.lsp.completion.enable(true, args.data.client_id, args.buf, { autotrigger = false })
  end,
})
map("i", "<C-Space>", vim.lsp.completion.get, { desc = "LSP completion" })

-- Markdown: fold by "#" headings only (za toggle, zc/zo close/open, zM/zR close/open all)
-- built-in ftplugin fold; treesitter's also folds lists and code blocks
vim.g.markdown_folding = 1
opt.foldlevelstart = 99  -- open files unfolded

-- Markdown todos: Space t adds "- [ ] " to the end of this file's "# TODO" list (creates it if missing),
-- Space x toggles the checkbox on the current line
local function todo_add()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local head
  for i, l in ipairs(lines) do
    if l:match("^#+%s+TODO%s*$") then head = i break end
  end
  local at  -- 0-based index to insert the new item at
  if not head then
    local add = (lines[#lines] or "") ~= "" and { "", "# TODO", "" } or { "# TODO", "" }
    vim.api.nvim_buf_set_lines(0, #lines, #lines, false, add)
    at = #lines + #add
  else
    for i = head + 1, #lines do
      if lines[i]:match("^#") then break end
      if lines[i]:match("^%s*[-*+] %[.%]") then at = i end
    end
    if not at then  -- empty list: keep a blank line under the heading
      at = head
      if lines[head + 1] == "" then at = head + 1 else vim.api.nvim_buf_set_lines(0, at, at, false, { "" }); at = at + 1 end
      if lines[head + 2] and lines[head + 2] ~= "" and lines[head + 1] == "" then
        vim.api.nvim_buf_set_lines(0, at, at, false, { "" })  -- blank line before the next section
      end
    end
  end
  vim.api.nvim_buf_set_lines(0, at, at, false, { "- [ ] " })
  vim.api.nvim_win_set_cursor(0, { at + 1, 0 })
  vim.cmd("startinsert!")
end
local function todo_toggle()
  local l = vim.api.nvim_get_current_line()
  local new = l:find("%[ %]") and l:gsub("%[ %]", "[x]", 1) or l:gsub("%[[xX]%]", "[ ]", 1)
  vim.api.nvim_set_current_line(new)
end
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    map("n", "<Leader>t", todo_add, { buffer = args.buf, desc = "Add todo to # TODO" })
    map("n", "<Leader>x", todo_toggle, { buffer = args.buf, desc = "Toggle checkbox" })
    map("n", "<Leader>T", function() require("fzf-lua").blines({ query = "'[ ] " }) end,
      { buffer = args.buf, desc = "Jump to open todo" })
  end,
})

-- Snippets: type the trigger, then Ctrl-J to expand; Ctrl-L / Ctrl-H jump between placeholders
local ls = require("luasnip")
ls.add_snippets("all", {
  ls.snippet("date", ls.function_node(function() return "# " .. os.date("%Y-%m-%d") end)),  -- "# 2026-11-12"
  -- date-1 = yesterday, date+2 = in two days (os.time rolls days over months and years)
  ls.snippet({ trig = "date([+-]%d+)", regTrig = true }, ls.function_node(function(_, snip)
    local t = os.date("*t")
    t.day = t.day + tonumber(snip.captures[1])
    return "# " .. os.date("%Y-%m-%d", os.time(t))
  end)),
  ls.snippet("todo", { ls.text_node({ "# TODO", "", "- [ ] " }), ls.insert_node(0) }),
  ls.snippet("tt", { ls.text_node("- [ ] "), ls.insert_node(0) }),
})
map("i", "<C-j>", function() if ls.expandable() then ls.expand() end end, { desc = "Expand snippet" })
-- Ctrl-L / Ctrl-H also jump in vim.snippet (LSP completion snippets); Neovim's Tab / Shift-Tab for that are removed
for _, mode in ipairs({ "i", "s" }) do
  pcall(vim.keymap.del, mode, "<Tab>")
  pcall(vim.keymap.del, mode, "<S-Tab>")
end
map({ "i", "s" }, "<C-l>", function()
  if vim.snippet.active({ direction = 1 }) then vim.snippet.jump(1) else ls.jump(1) end
end, { desc = "Next snippet placeholder" })
map({ "i", "s" }, "<C-h>", function()  -- outside a snippet: normal Ctrl-H (backspace)
  if vim.snippet.active({ direction = -1 }) then vim.snippet.jump(-1)
  elseif ls.jumpable(-1) then ls.jump(-1)
  else vim.api.nvim_feedkeys(vim.keycode("<C-h>"), "ni", false) end
end, { desc = "Previous snippet placeholder / backspace" })
