-- Here is a more advanced example where we pass configuration
-- options to `gitsigns.nvim`. This is equivalent to the following Lua:
--    require('gitsigns').setup({ ... })
--
-- See `:help gitsigns` to understand what the configuration keys do
return { -- Adds git related signs to the gutter, as well as utilities for managing changes
  'lewis6991/gitsigns.nvim',
  opts = {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    signcolumn = true,
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
      end

        -- stylua: ignore start
        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")
        map({ "n", "v" }, "<leader>hgs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>hgr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>hgS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>hgu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>hgR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>hgp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>hgb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>hgd", gs.diffthis, "Diff This")
        map("n", "<leader>hgD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
    end,
  },
}
