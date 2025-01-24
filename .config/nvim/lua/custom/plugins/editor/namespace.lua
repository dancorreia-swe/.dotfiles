return { -- lazy
  'ccaglak/namespace.nvim',
  keys = {
    { '<leader>la', '<cmd>Php classes<cr>', desc = 'Find all classes, traits, implementations, and attributes from Composer or local search' },
    { '<leader>lc', '<cmd>Php class<cr>', desc = 'Get the class under the cursor' },
    { '<leader>ln', '<cmd>Php namespace<cr>', desc = 'Generate namespace for the current file' },
    { '<leader>ls', '<cmd>Php sort<cr>', desc = 'Sorts namespaces in current file with 6 options' },
  },
  dependencies = {
    'ccaglak/phptools.nvim', -- optional
    'ccaglak/larago.nvim', -- optional
  },
  config = function()
    require('namespace').setup {
      ui = true, -- default: true -- false only if you want to use your own ui
      cacheOnload = false, -- default: false -- cache composer.json on load
      dumpOnload = false, -- default: false -- dump composer.json on load
      sort = {
        on_save = false, -- default: false -- sorts on every search
        sort_type = 'length_desc', -- default: natural -- seam like what pint is sorting
        --  ascending -- descending -- length_asc
        -- length_desc -- natural -- case_insensitive
      },
    }
  end,
}
