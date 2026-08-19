-- Markdown fenced code block syntax highlighting
--
-- Highlighting (including injections into ```py / ```bash etc. fenced blocks)
-- is handled by Neovim's tree-sitter engine, started via the FileType autocmd
-- in plugin/treesitter.lua. Each embedded language just needs its parser
-- installed; add languages to the install list there and run :TSInstall.

-- Markdown-specific settings
local opt = vim.opt_local

opt.wrap = true      -- Wrap lines at the end of the screen
opt.linebreak = true -- Break at word boundaries
opt.textwidth = 0    -- Don't auto-insert line breaks

-- Better navigation with wrapped lines
-- Moving by display lines instead of physical lines
vim.keymap.set({ "n", "v" }, "j", "gj", { buffer = true, desc = "Move down by display line" })
vim.keymap.set({ "n", "v" }, "k", "gk", { buffer = true, desc = "Move up by display line" })
vim.keymap.set({ "n", "v" }, "0", "g0", { buffer = true, desc = "Go to start of display line" })
vim.keymap.set({ "n", "v" }, "$", "g$", { buffer = true, desc = "Go to end of display line" })

-- Spell checking
opt.spell = true
opt.spelllang = "en_us"

-- Wikilink support for gf ([[entities/forefront]] -> entities/forefront.md)
opt.suffixesadd:append(".md")
vim.opt_local.includeexpr = "v:lua.resolve_wikilink(v:fname)"

---@diagnostic disable-next-line: duplicate-set-field
function _G.resolve_wikilink(fname)
  -- Strip [[ and ]] if present
  return fname:gsub("%[%[", ""):gsub("%]%]", "")
end

local function github_slug(heading)
  return heading:lower():gsub("[^%w%s_-]", ""):gsub("%s", "-")
end

local function anchor_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local cursor_column = vim.api.nvim_win_get_cursor(0)[2] + 1
  local search_from = 1

  while true do
    local link_start, link_end, destination = line:find("%b[]%(([^%)]+)%)", search_from)
    if not link_start then
      return nil
    end
    if cursor_column >= link_start and cursor_column <= link_end then
      return destination:match("^#(.+)$")
    end
    search_from = link_end + 1
  end
end

local function follow_heading_link()
  local anchor = anchor_under_cursor()
  if not anchor then
    vim.cmd.normal { args = { "+" }, bang = true }
    return
  end

  local used_slugs = {}
  for row, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local hashes, heading = line:match("^%s*(#+)%s+(.+)$")
    if hashes and #hashes <= 6 then
      heading = heading:gsub("%s+#+%s*$", ""):gsub("%s+$", "")
      local base_slug = github_slug(heading)
      local slug = base_slug
      local suffix = 0
      while used_slugs[slug] do
        suffix = suffix + 1
        slug = base_slug .. "-" .. suffix
      end
      used_slugs[slug] = true

      if slug == anchor then
        vim.cmd.normal { args = { row .. "Gzz" }, bang = true }
        return
      end
    end
  end

  vim.notify("Markdown heading not found: #" .. anchor, vim.log.levels.WARN)
end

vim.keymap.set("n", "<CR>", follow_heading_link, { buffer = true, desc = "Follow Markdown heading link" })
