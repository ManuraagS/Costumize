vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
    config = function()
      require "options"
    end,
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

require("transparent").setup({ -- Optional, you don't have to run setup.
  groups = { -- table: default groups
    'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
    'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
    'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
    'SignColumn', 'CursorLine', 'CursorLineNr', 'StatusLine', 'StatusLineNC',
    'EndOfBuffer',
  },
  extra_groups = {}, -- table: additional groups that should be cleared
  exclude_groups = {}, -- table: groups you don't want to clear
})


-- Set C++ file type
vim.api.nvim_command('autocmd BufNewFile,BufRead *.cpp set filetype=cpp')

-- Compile and run C++ program in subshell
_G.CompileAndRun = function()
  local fileName = vim.api.nvim_buf_get_name(0)
  if fileName:match('%.cpp$') then
    local exeName = fileName:gsub('%.cpp$', '')
    vim.api.nvim_command('w')
    vim.api.nvim_exec('!g++ -std=c++11 -Wall -Wextra -Wpedantic -O2 -o ' .. exeName .. ' ' .. fileName, true)
    if vim.v.shell_error == 0 then
      local cmd = "x-terminal-emulator -e bash -c './" .. exeName .. "; read -p \"Press enter to exit...\"'"
      vim.fn.system(cmd)
      vim.api.nvim_command('redraw!')
    end
  else
    print('Not a C++ file')
  end
end

-- Map keys to compile and run current file
vim.api.nvim_set_keymap('n', '<F5>', ':lua CompileAndRun()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F9>', ':w<CR>:!clear<CR>:lua CompileAndRun()<CR>', { noremap = true, silent = true })

