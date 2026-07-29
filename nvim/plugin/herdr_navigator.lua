-- Seamless vim <-> herdr pane navigation: the vim half of the
-- vim-tmux-navigator pattern, talking to herdr instead of tmux.
--
-- The herdr side (direct ctrl+h/j/k/l chords -> herdr-config scripts/h-nav)
-- passes the chord through to nvim when it is the pane's foreground
-- process. These mappings move between vim windows and hand off to herdr
-- when the move hits the edge of vim's layout.
--
-- init.lua sets g:tmux_navigator_no_mappings under the same condition so
-- vim-tmux-navigator keeps working unchanged inside tmux.
if vim.env.HERDR_ENV ~= "1" or vim.env.TMUX then
  return
end

local function navigate(wincmd, direction)
  local win = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(wincmd)
  if vim.api.nvim_get_current_win() == win then
    -- At the edge: no vim window in that direction, ask herdr to move.
    vim.system({ "herdr", "pane", "focus", "--direction", direction, "--current" })
  end
end

for key, m in pairs({
  ["<C-h>"] = { "h", "left" },
  ["<C-j>"] = { "j", "down" },
  ["<C-k>"] = { "k", "up" },
  ["<C-l>"] = { "l", "right" },
}) do
  vim.keymap.set("n", key, function()
    navigate(m[1], m[2])
  end, { silent = true, desc = "Go to window / herdr pane " .. m[2] })
end
