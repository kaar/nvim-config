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

-- In normal mode, <CR> follows the Markdown link under the cursor: headings
-- jump within Neovim, files open like gf, and web links open like gx.
-- See examples/markdown-links.md for supported links and manual test cases.
local function github_slug(heading)
  return heading:lower():gsub("[^%w%s_-]", ""):gsub("%s", "-")
end

local function inline_link_under_cursor(line, cursor_column)
  local search_from = 1

  while true do
    local link_start, label_end = line:find("%b[]", search_from)
    if not link_start then
      return nil
    end

    local parentheses_start, link_end = line:find("%b()", label_end + 1)
    if parentheses_start == label_end + 1 then
      if cursor_column >= link_start and cursor_column <= link_end then
        local contents = line:sub(parentheses_start + 1, link_end - 1)
        local whitespace, destination = contents:match("^(%s*)<([^>]+)>")
        local destination_column
        if destination then
          destination_column = parentheses_start + #whitespace + 1
        else
          whitespace, destination = contents:match("^(%s*)(%S+)")
          destination_column = parentheses_start + #whitespace
        end
        if destination then
          return { destination = destination, column = destination_column }
        end
        return nil
      end
      search_from = link_end + 1
    else
      search_from = label_end + 1
    end
  end
end

local function wikilink_under_cursor(line, cursor_column)
  local search_from = 1

  while true do
    local link_start, link_end, destination = line:find("%[%[([^]|]+)[^%]]*%]%]", search_from)
    if not link_start then
      return nil
    end
    if cursor_column >= link_start and cursor_column <= link_end then
      return { destination = destination, column = link_start + 1 }
    end
    search_from = link_end + 1
  end
end

local function web_link_under_cursor(line, cursor_column)
  local search_from = 1

  while true do
    local link_start, link_end, destination = line:find("(%a[%w+.-]*:[^%s<>]+)", search_from)
    if not link_start then
      return nil
    end
    destination = destination:gsub("[.,;!?]+$", "")
    link_end = link_start + #destination - 1
    if cursor_column >= link_start and cursor_column <= link_end then
      return { destination = destination, column = link_start - 1 }
    end
    search_from = link_end + 1
  end
end

local function link_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local cursor_column = vim.api.nvim_win_get_cursor(0)[2] + 1
  return inline_link_under_cursor(line, cursor_column)
    or wikilink_under_cursor(line, cursor_column)
    or web_link_under_cursor(line, cursor_column)
end

local function follow_heading_link(anchor)
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

local function follow_markdown_link()
  local link = link_under_cursor()
  if not link then
    return
  end

  if link.destination:match("^%a[%w+.-]*:") then
    local _, error_message = vim.ui.open(link.destination)
    if error_message then
      vim.notify(error_message, vim.log.levels.ERROR)
    end
    return
  end

  local anchor = link.destination:match("^#(.+)$")
  if anchor then
    follow_heading_link(anchor)
    return
  end

  local _, file_anchor = link.destination:match("^(.-)#(.+)$")
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_win_set_cursor(0, { row, link.column })

  if file_anchor then
    local isfname = vim.o.isfname
    vim.o.isfname = isfname:gsub(",#", "")
    local opened, error_message = pcall(vim.cmd.normal, { args = { "gf" }, bang = true })
    vim.o.isfname = isfname
    if not opened then
      error(error_message)
    end
    follow_heading_link(file_anchor)
    return
  end

  vim.cmd.normal { args = { "gf" }, bang = true }
end

vim.keymap.set("n", "<CR>", follow_markdown_link, { buffer = true, desc = "Follow Markdown link" })
