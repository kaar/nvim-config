-- Open the current file in GitHub
-- Keymapping: gh
local function open_in_github()
  local filepath = vim.fn.expand("%:p:~:.") -- Get the relative path
  local command = "gh browse " .. filepath .. ":" .. vim.fn.line(".")
  vim.fn.system(command)
end

vim.keymap.set("n", "gh", open_in_github, { silent = true, desc = "Open the current file in GitHub" })
