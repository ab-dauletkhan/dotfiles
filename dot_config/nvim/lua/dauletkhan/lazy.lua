local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not vim.uv.fs_stat(lazypath) then
  vim.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }):wait()
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'neanias/everforest-nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('everforest').setup({
        background = 'medium',
        transparent_background_level = 1,
        italics = true,
      })
      vim.cmd.colorscheme('everforest')
    end,
  },

  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('fzf-lua').setup({
        fzf_colors = true,
        winopts = {
          height = 0.85,
          width = 0.85,
          preview = {
            layout = 'flex',
            vertical = 'down:45%',
            horizontal = 'right:55%',
          },
        },
      })
    end,
  },

  {
    'stevearc/oil.nvim',
    config = function()
      require('oil').setup({
        default_file_explorer = true,
        view_options = {
          show_hidden = true,
        },
      })
    end,
  },

  {
    'lewis6991/gitsigns.nvim',
    config = true,
  },

  {
    'stevearc/quicker.nvim',
    config = true,
  },

  {
    'nvim-mini/mini.completion',
    config = function()
      require('mini.completion').setup()
    end,
  },

  {
    'neovim/nvim-lspconfig',
  },
})
