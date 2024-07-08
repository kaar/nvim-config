# Nvim Plugins

Using [Lazy](https://github.com/folke/lazy.nvim) and specifices import
`./nvim/lua/plugins/` from where each file will expect to return a plugin
specification.

`./nvim/init.lua`
```lua
-- This loads all the plugins directly from ./lua/plugins/*
-- Took inspiration from https://github.com/tjdevries/config.nvim
require("lazy").setup({ import = "plugins" }, {
  change_detection = {
    notify = false,
  },
})
```

## Example
GitHub Copilot

```lua
-- https://github.com/github/zbirenbaum/copilot.lua
-- Accept: <C-e>
-- Open: <M-CR>
-- Jump to next: <M-]>
-- Jump to prev: <M-[>
return {
	{
		"zbirenbaum/copilot.lua",
		dependencies = {
			{ "hrsh7th/nvim-cmp" },
		},
		enabled = true,
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
			require("copilot").setup({
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
			})
		end,
	},
}
```
