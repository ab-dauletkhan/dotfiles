vim.api.nvim_create_user_command('GitBlameLine', function()
  local line_number = vim.fn.line('.')
  local filename = vim.api.nvim_buf_get_name(0)

  local result = vim.system({
    'git',
    'blame',
    '-L',
    line_number .. ',+1',
    filename,
  }):wait()

  print(result.stdout)
end, {
  desc = 'Print git blame for current line',
})
