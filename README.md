# nvim

A single-file Neovim config (`init.lua`) for Neovim 0.12+, using the built-in plugin manager (`vim.pack`), built-in LSP and built-in completion.

## Requirements

- Neovim 0.12+
- `git` (vim.pack installs plugins with it)
- nvim-treesitter: [`tree-sitter` CLI](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md) 0.26.1+ (from a package manager, not npm), a C compiler, `tar`, `curl`
- fzf-lua: `fzf` 0.36+, `ripgrep`, `fd`
- Node.js / npm and [uv](https://docs.astral.sh/uv/) for the language servers below

## Install

```sh
git clone git@github.com:shakthitechinc/nvim.git ~/.config/nvim
nvim   # vim.pack installs the plugins on first start
```

Plugins: vague.nvim (colorscheme), nvim-lspconfig, conform.nvim (formatting), nvim-treesitter, LuaSnip, fzf-lua.

### Tools

The language servers and formatters are separate programs and need to be on `PATH`. npm packages go to `~/.local` so they survive Node version switches.

```sh
# ripgrep + fd for fzf-lua
sudo apt install ripgrep fd-find && ln -s "$(which fdfind)" ~/.local/bin/fd

# Python
uv tool install pyrefly
uv tool install ruff

# JS / TS / Vue / JSON / HTML / CSS / YAML / Emmet, and the formatter
npm install -g --prefix ~/.local typescript@7 @vtsls/language-server @vue/language-server \
  vscode-langservers-extracted yaml-language-server @olrtg/emmet-language-server oxfmt
```

Also on `PATH`: `lua-language-server`, plus the release binaries of [superhtml](https://github.com/kristoff-it/superhtml/releases) and [jinja-lsp](https://github.com/uros-5/jinja-lsp/releases).

## Language servers

| Files | Server |
|---|---|
| `.py` | pyrefly + ruff |
| `.ts` `.tsx` `.js` | tsc (TypeScript 7, `tsc --lsp`) |
| `.vue` | vue_ls + vtsls (`.vue` only, via `@vue/typescript-plugin`) |
| `.html` | superhtml (HTML) + vscode-html (CSS in `<style>` only) + Emmet |
| `.jinja` `.j2` | jinja-lsp + vscode-html + Emmet |
| `.css` | cssls + Emmet |
| `.json` | jsonls |
| `.yaml` | yamlls |
| `.lua` | lua_ls |

Formatting (`Space F`, never on save): ruff for Python, oxfmt for JS/TS/Vue/JSON/HTML/CSS/YAML. A project's own `node_modules` oxfmt wins.

Jinja templates use `.jinja` / `.j2` so `.html` stays plain HTML.

## Keys

Leader is `Space`. `Space k` searches every key with its description.

| Key | Action |
|---|---|
| `Space w` / `q` / `e` | Save / quit / file explorer |
| `Space y` / `p` | Yank to / paste from clipboard |
| `Space F` | Format |
| `Space f` / `o` / `b` | Find files / recent files / open buffers |
| `Space g` / `*` | Grep project / grep word (or selection) |
| `Space /` | Lines in file |
| `Space r` | Resume last search |
| `Space d` / `D` | Diagnostics in project / file |
| `Space S` | Symbols in project |
| `Space s` / `c` | Git status / changed hunks |
| `Space l` / `L` / `B` | Git log of file / project, branches |
| `Space h` / `:` / `k` | Help / commands / keymaps |
| `Space m` / `"` / `j` / `u` / `Q` | Marks / registers / jumps / undo tree / quickfix |
| `gd` `grr` `gri` `gO` `gra` | Definitions, references, implementations, file symbols, code actions (fzf-lua) |
| `grn` `grt` `K` `]d` `[d` | Rename, type definition, hover, next/previous diagnostic (Neovim defaults) |
| `Ctrl+Space` | Completion (insert mode) |
| `Ctrl+J` | Expand snippet |
| `Ctrl+L` / `Ctrl+H` | Next / previous snippet placeholder (`Ctrl+H` is backspace outside a snippet) |

Tab is never used for snippets.

## Snippets

- `date` → `# 2026-11-13` (today)
- `date-1`, `date+2`, ... → days from today
- `todo` → `# TODO` heading with a `- [ ] ` item
- `tt` → `- [ ] `

## Markdown

Folds by `#` headings only: `za` toggle, `zM` / `zR` close / open all.

Todos (Markdown files only):

| Key | Action |
|---|---|
| `Space t` | Add `- [ ] ` to the end of this file's `# TODO` list (creates the heading if missing) |
| `Space x` | Toggle the checkbox on the current line |
| `Space T` | Jump to an open todo (fzf-lua) |
