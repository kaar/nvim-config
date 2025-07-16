-- https://github.com/zbirenbaum/copilot.lua
-- Accept: <C-e>
-- Open: <M-CR>
-- Jump to next: <M-]>
-- Jump to prev: <M-[>
--

-- Only enable if has network to prevent errors when offline
local function has_network()
  return os.execute "ping -c1 -W1 google.com >/dev/null 2>&1" == 0
end

return {
  {
    "zbirenbaum/copilot.lua",
    dependencies = {
      { "hrsh7th/nvim-cmp" },
    },
    enabled = false,
    cmd = "Copilot",
    event = "InsertEnter",
    keymap = {
      jump_prev = "[[",
      jump_next = "]]",
      accept = "<CR>",
      refresh = "gr",
      open = "<M-CR>",
    },
    config = function()
      require("copilot").setup {
        -- Open panel with <M-CR> (Alt + Enter)
        panel = {
          enabled = true,
          auto_refresh = true,
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<C-e>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        filetypes = {
          yaml = true,
          markdown = true,
          help = true,
          gitcommit = true,
          gitrebase = true,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
      }
    end,
  },
}
