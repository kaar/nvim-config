vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Install package manager (https://github.com/folke/lazy.nvim)
-- See `:help lazy.nvim.txt`
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- This loads all the plugins directly from ./lua/plugins/*
-- Took inspiration from https://github.com/tjdevries/config.nvim
require("lazy").setup({ import = "plugins" }, {
  change_detection = {
    notify = false,
  },
})
-- TODO:
-- https://github.com/jackMort/ChatGPT.nvim
-- https://github.com/sindrets/diffview.nvim

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight yanked text
local yank_group = augroup("HighlightYank", {})
autocmd("TextYankPost", {
  group = yank_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank {
      higroup = "IncSearch",
      timeout = 40,
    }
  end,
})

-- Remember cursor position
local cursor_group = augroup("RememberCursor", {})
autocmd("BufReadPost", {
  group = cursor_group,
  pattern = "*",
  callback = function()
    local last_pos = vim.fn.line "'\""
    if last_pos > 1 and last_pos <= vim.fn.line "$" then
      vim.cmd 'normal! g`"'
      vim.cmd "normal zz"
    end
  end,
})

-- Trim trailing whitespace on save
local trim_group = augroup("TrimWhitespace", {})
autocmd({ "BufWritePre" }, {
  group = trim_group,
  pattern = "*",
  command = [[%s/\s\+$//e]],
})
