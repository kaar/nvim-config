return {
  {
    -- https://supermaven.com, replacement for copilot
    -- https://github.com/supermaven-inc/supermaven-nvim
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<C-e>",
          clear_suggestion = "<C-]>",
          accept_word = "<C-j>",
        },
        condition = function()
          return true
        end,
      })
    end,
  }
}
