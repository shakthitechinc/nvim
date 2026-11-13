# nvim

A single-file Neovim config (`init.lua`) for Neovim 0.12+, using the built-in plugin manager (`vim.pack`), built-in LSP and built-in completion.

## Requirements

- Neovim 0.12+
- `git` (vim.pack installs plugins with it)
- nvim-treesitter: [`tree-sitter` CLI](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md) 0.26.1+ (from a package manager, not npm), a C compiler, `tar`, `curl`
- fzf-lua: [skim](https://github.com/skim-rs/skim) (`sk`, used via fzf-lua's `skim` profile; or `fzf` 0.36+ with `fzf.setup({})`), `ripgrep`, `fd`
- Node.js / npm and [uv](https://docs.astral.sh/uv/) for the language servers below
- Clipboard (`Space y` / `Space p`): on WSL, `win32yank.exe` on `PATH` (it ships with Windows Neovim in `C:\Program Files\Neovim\bin`); on Linux, `wl-clipboard` or `xclip`

## Install

```sh
git clone git@github.com:shakthitechinc/nvim.git ~/.config/nvim
nvim   # vim.pack installs the plugins on first start
```

Plugins: vague.nvim (colorscheme), nvim-lspconfig, conform.nvim (formatting), nvim-treesitter, LuaSnip, fzf-lua (running skim).

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

Release binaries, also on `PATH`:

- [superhtml](https://github.com/kristoff-it/superhtml/releases) (`superhtml`)
- [jinja-lsp](https://github.com/uros-5/jinja-lsp/releases) (`jinja-lsp`)
- [lua-language-server](https://github.com/LuaLS/lua-language-server/releases/latest): extract the release somewhere, then put a wrapper on `PATH` (its docs prefer this over a symlink):

  ```sh
  printf '#!/bin/sh\nexec "%s/bin/lua-language-server" "$@"\n' "$HOME/path/to/lua-language-server" > ~/.local/bin/lua-language-server
  chmod +x ~/.local/bin/lua-language-server
  ```

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

Python: the nearest `pyrefly.toml` up the tree is Pyrefly's config, even past an app's own `pyproject.toml`. For a Frappe bench (a folder with `env/` and `apps/`, venv built in Docker), put one `pyrefly.toml` in the bench folder; every `apps/<name>` with `<name>/hooks.py` is added as a search path automatically (`:lsp restart` after adding an app):

```toml
skip-interpreter-query = true
python-version = "3.14"
site-packages-path = ["env/lib/python3.14/site-packages"]
```

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
