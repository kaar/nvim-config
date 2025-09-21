-- https://github.com/ThePrimeagen/harpoon
-- Uses the harpoon2 branch
-- https://github.com/ThePrimeagen/harpoon/tree/harpoon2
return {
  "ThePrimeagen/harpoon",
  dependencies = { "nvim-lua/plenary.nvim" },
  branch = "harpoon2",
  config = function()
    local harpoon = require "harpoon"
    harpoon:setup()

    vim.keymap.set("n", "<leader>m", function()
      harpoon:list():add()
    end, { desc = "[M]ark file with Harpoon" })
    vim.keymap.set("n", "<leader>l", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "[L]ist Harpoon files" })

    -- Set <space>1..<space>5 be my shortcuts to moving to the files
    for _, idx in ipairs { 1, 2, 3, 4, 5 } do
      vim.keymap.set("n", string.format("<space>%d", idx), function()
        harpoon:list():select(idx)
      end)
    end
  end,
}
