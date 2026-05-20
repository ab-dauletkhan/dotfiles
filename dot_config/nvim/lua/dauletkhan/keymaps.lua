local map = vim.keymap.set

-- Window navigation
map({ 't', 'i' }, '<leader>h', '<C-\\><C-n><C-w>h', { desc = 'Move to left window' })
map({ 't', 'i' }, '<leader>j', '<C-\\><C-n><C-w>j', { desc = 'Move to lower window' })
map({ 't', 'i' }, '<leader>k', '<C-\\><C-n><C-w>k', { desc = 'Move to upper window' })
map({ 't', 'i' }, '<leader>l', '<C-\\><C-n><C-w>l', { desc = 'Move to right window' })
map('n', '<leader>h', '<C-w>h', { desc = 'Move to left window' })
map('n', '<leader>j', '<C-w>j', { desc = 'Move to lower window' })
map('n', '<leader>k', '<C-w>k', { desc = 'Move to upper window' })
map('n', '<leader>l', '<C-w>l', { desc = 'Move to right window' })

-- Terminal
map('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Buffers
map('n', '<S-l>', ':bnext<CR>', { desc = 'Next buffer' })
map('n', '<S-h>', ':bprevious<CR>', { desc = 'Previous buffer' })
map('n', '<leader>bd', ':bdelete<CR>', { desc = 'Delete buffer' })

-- Clear search
map('n', '<Esc>', ':nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Keep visual selection when indenting
map('v', '<', '<gv')
map('v', '>', '>gv')

-- Oil
map('n', '<leader>e', '<cmd>Oil<CR>', { desc = 'Open file explorer' })
map('n', '<leader>E', '<cmd>Oil .<CR>', { desc = 'Open project root explorer' })

-- FZF
local function fzf(method)
  return function() require('fzf-lua')[method]() end
end

-- Files
map('n', '<leader>ff', fzf('files'), { desc = 'Find files' })
map('n', '<leader>fr', fzf('oldfiles'), { desc = 'Recent files' })
map('n', '<leader>fb', fzf('buffers'), { desc = 'Find buffers' })

-- Search
map('n', '<leader>sg', fzf('live_grep'), { desc = 'Live grep' })
map('n', '<leader>sw', fzf('grep_cword'), { desc = 'Search word under cursor' })
map('v', '<leader>sw', fzf('grep_visual'), { desc = 'Search visual selection' })

-- Neovim
map('n', '<leader>sh', fzf('helptags'), { desc = 'Search help' })
map('n', '<leader>sk', fzf('keymaps'), { desc = 'Search keymaps' })
map('n', '<leader>sc', fzf('commands'), { desc = 'Search commands' })

-- Git
map('n', '<leader>gf', fzf('git_files'), { desc = 'Git files' })
map('n', '<leader>gs', fzf('git_status'), { desc = 'Git status' })
map('n', '<leader>gc', fzf('git_commits'), { desc = 'Git commits' })

-- Diagnostics / quickfix
map('n', '<leader>sd', fzf('diagnostics_document'), { desc = 'Document diagnostics' })
map('n', '<leader>sD', fzf('diagnostics_workspace'), { desc = 'Workspace diagnostics' })
map('n', '<leader>fq', fzf('quickfix'), { desc = 'Quickfix list' })
