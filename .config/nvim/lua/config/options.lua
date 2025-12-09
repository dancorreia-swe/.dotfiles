-- Array of file names indicating root directory. Modify to your liking.
local root_names = { '.git', 'Makefile' }

-- Cache to use for speed up (at cost of possibly outdated results)
local root_cache = {}

local set_root = function()
  -- Get directory path to start search from
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then
    return
  end
  path = vim.fs.dirname(path)

  -- Try cache and resort to searching upward for root directory
  local root = root_cache[path]
  if root == nil then
    local root_file = vim.fs.find(root_names, { path = path, upward = true })[1]
    if root_file == nil then
      return
    end
    root = vim.fs.dirname(root_file)
    root_cache[path] = root
  end

  -- Set current directory
  vim.fn.chdir(root)
end

local root_augroup = vim.api.nvim_create_augroup('MyAutoRoot', {})
vim.api.nvim_create_autocmd('BufEnter', { group = root_augroup, callback = set_root })

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- Disables netrw
-- vim.g.loaded_netrw = 1

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- if the completion engine supports the AI source,
-- use that instead of inline suggestions
vim.g.ai_cmp = false

vim.diagnostic.config { jump = { float = true } }

local opt = vim.opt

-- Make line numbers default
opt.number = true
opt.relativenumber = true

opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup

opt.ruler = false -- Disable the default ruler
opt.scrolloff = 4 -- Lines of context

opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append { W = true, I = true, c = true, C = true }

opt.showmode = false -- Dont show mode since we have a statusline

opt.sidescrolloff = 8 -- Columns of context

opt.signcolumn = 'yes' -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically

opt.tabstop = 2 -- Number of spaces tabs count for
opt.smoothscroll = true
opt.spelllang = { 'en' }

-- Enable mouse mode, can be useful for resizing splits for example!
opt.mouse = 'a'
opt.mousemoveevent = true

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
opt.clipboard = vim.env.SSH_TTY and '' or 'unnamedplus' -- Sync with system clipboard
opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer

opt.expandtab = true -- Use spaces instead of tabs

opt.fillchars = {
  foldopen = '',
  foldclose = '',
  fold = ' ',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
}
opt.foldlevel = 99
opt.foldmethod = 'indent'
opt.foldtext = ''
opt.grepprg = 'rg --vimgrep'
opt.ignorecase = true -- Ignore case
opt.inccommand = 'nosplit' -- preview incremental substitute
opt.jumpoptions = 'view'

opt.linebreak = true -- Wrap lines at convenient points

--  See `:help 'list'`
--  and `:help 'listchars'`
opt.list = true -- Show some invisible characters (tabs...
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Enable break indent
opt.breakindent = true

-- Save undo history
opt.undofile = true
opt.undolevels = 10000

opt.ignorecase = true
opt.smartcase = true

-- Keep signcolumn on by default
opt.signcolumn = 'yes'

-- Decrease update time
opt.updatetime = 200 -- Save swap file and trigger CursorHold

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
opt.timeoutlen = 300

-- Configure how new splits should be opened
opt.splitkeep = 'screen'
opt.splitright = true
opt.splitbelow = true

-- Preview substitutions live, as you type!
opt.inccommand = 'split'

-- Show which line your cursor is on
opt.cursorline = true
opt.cursorcolumn = true

-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 10

-- Enable line wrapping
opt.laststatus = 3

-- Hide deprecation warnings
vim.g.deprecation_warnings = false

opt.termguicolors = true -- True color support

opt.timeoutlen = vim.g.vscode and 1000 or 300 -- Lower than default (1000) to quickly trigger which-key

opt.virtualedit = 'block' -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = 'longest:full,full' -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width

opt.wrap = false -- Disable line wrap

vim.g.markdown_recommended_style = 0
