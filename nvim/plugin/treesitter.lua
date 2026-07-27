-- Tree-sitter setup for Neovim 0.12+
--
-- Neovim ships the tree-sitter engine and the highlight/injection/fold runtime.
-- The nvim-treesitter plugin (main branch) is only a parser + query manager:
--   :TSInstall <lang> / :TSUpdate    install and update parsers
-- Parsers land in stdpath('data')/site/parser/ as .so files, so the manual
-- `tree-sitter build` workflow is no longer needed.
--
-- Requirements (once): `brew install tree-sitter-cli`, plus tar, curl and a C
-- compiler on PATH.

-- Parsers to keep installed. Includes the languages used inside markdown/mdx
-- fenced code blocks and JSX (typescript/tsx for mdx.nvim injections).
require("nvim-treesitter").install {
  "markdown",
  "markdown_inline",
  "typescript",
  "tsx",
  "javascript",
  "python",
  "bash",
  "lua",
  "json",
  "yaml",
  "go",
  "rust",
  "c",
}

-- Highlighting is opt-in per buffer. Start it for any buffer whose filetype has
-- a parser; pcall keeps it a no-op for filetypes without one.
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
