-- ============================================================================
-- FLOATING TERMINAL
-- https://github.com/radleylewis/nvim-lite/blob/youtube_demo/init.lua
-- ============================================================================

local terminal_state = {
  buf = nil,
  win = nil,
  is_open = false,
}

local function FloatingTerminal()
  if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
    vim.api.nvim_win_close(terminal_state.win, false)
    terminal_state.is_open = false
    return
  end

  if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
    terminal_state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[terminal_state.buf].bufhidden = "hide"
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })

  vim.api.nvim_set_hl(0, "FloatingTermNormal", { bg = "none" })
  vim.api.nvim_set_hl(0, "FloatingTermBorder", { bg = "none" })
  vim.api.nvim_set_option_value("winblend", 0, { win = terminal_state.win })
  vim.api.nvim_set_option_value("winhighlight", "Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder",
    { win = terminal_state.win })

  if vim.api.nvim_buf_line_count(terminal_state.buf) <= 1 and vim.api.nvim_buf_get_lines(terminal_state.buf, 0, 1, false)[1] == "" then
    vim.fn.jobstart(os.getenv("SHELL"), { term = true })
  end

  terminal_state.is_open = true
  vim.cmd "startinsert"

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = terminal_state.buf,
    once = true,
    callback = function()
      if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
        vim.api.nvim_win_close(terminal_state.win, false)
        terminal_state.is_open = false
      end
    end,
  })
end

local function CloseFloatingTerminal()
  if terminal_state.is_open then
    vim.api.nvim_win_close(terminal_state.win, false)
    terminal_state.is_open = false
  end
end

-- Key mappings
vim.keymap.set("n", "<leader>t", FloatingTerminal, { noremap = true, silent = true, desc = "Toggle floating terminal" })
vim.keymap.set("t", "<Esc><Esc>", CloseFloatingTerminal, { noremap = true, silent = true, desc = "Close terminal" })
