-- Open Herdr scrollback at the bottom.
--
-- Herdr's built-in `edit_scrollback` action (bound to `<leader>e` in Herdr)
-- dumps the full pane scrollback to $TMPDIR/herdr-scrollback-<pid>-<nanos>-<n>.txt
-- and runs `${EDITOR:-vi} "<file>"`. Neovim then opens at line 1, the oldest
-- output, but the output of interest is almost always the most recent.
--
-- Why an autocmd here instead of changing Herdr:
-- - Herdr has no option to set the editor command or the initial cursor line.
-- - A custom Herdr command using `herdr pane read` is capped at 1000 lines,
--   while the built-in action reads the full scrollback.
-- - Changing $EDITOR (for example to `nvim +`) would affect every program.
--
-- Matching on the filename keeps the change scoped to Herdr scrollback files.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("HerdrScrollback", {}),
  pattern = "*/herdr-scrollback-*.txt",
  command = "normal! G",
})
