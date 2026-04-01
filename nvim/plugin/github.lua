-- Open the current file in GitHub
vim.keymap.set("n", "gh", function()
  local filepath = vim.fn.expand "%:p:~:."
  local command = "gh browse " .. filepath .. ":" .. vim.fn.line "."
  vim.fn.system(command)
end, { noremap = true, silent = true, desc = "Open the current file in GitHub" })
