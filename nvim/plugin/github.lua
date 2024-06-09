-- Open the current file in GitHub
-- Keymapping: gh
function GitHub()
  -- Open the current file in GitHub
  local filepath = vim.fn.expand "%:p:~:." -- Get the relative path
  local command = "gh browse " .. filepath .. ":" .. vim.fn.line "."
  vim.fn.system(command)
end

vim.api.nvim_set_keymap(
  "n",
  "gh",
  ":lua GitHub()<CR>",
  { noremap = false, silent = true, desc = "Open the current file in GitHub" }
)
