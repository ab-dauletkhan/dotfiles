vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.number = true
vim.o.relativenumber = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.sidescrolloff = 8

vim.o.confirm = true
vim.o.termguicolors = true

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.o.listchars = 'tab:» ,trail:·,nbsp:␣'

vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2

vim.o.undofile = true
vim.o.signcolumn = 'yes'

vim.o.updatetime = 250
vim.o.timeoutlen = 400

vim.api.nvim_create_autocmd('UIEnter', {
  callback = function()
    vim.o.clipboard = 'unnamedplus'
  end,
})
