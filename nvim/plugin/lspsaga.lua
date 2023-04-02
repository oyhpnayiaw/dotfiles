local status, saga = pcall(require, "lspsaga")
if (not status) then return end

local api, util = vim.api, vim.lsp.util

saga.setup {
  ui = {
    kind = require("catppuccin.groups.integrations.lsp_saga").custom_kind(),
    border = 'single',
    winblend = 0,
    colors = {
      normal_bg = '#1c1c19',
    }
  },
  request_timeout = 8000,
  lightbulb = {
    enable = true,
    enable_in_insert = true,
    cache_code_action = true,
    sign = true,
    update_time = 150,
    sign_priority = -1,
    -- virtual_text = true,
  },
  symbol_in_winbar = {
    enable = false,
  },
  finder = {
    keys = {
      expand_or_jump = '<CR>',
    },
  },
  outline = {
    win_position = 'right',
    win_with = '',
    win_width = 30,
    show_detail = true,
    auto_preview = true,
    auto_refresh = true,
    auto_close = true,
    custom_sort = nil,
    keys = {
      jump = 'o',
      expand_collapse = 'u',
      quit = 'q',
    },
  },
  rename = {
    quit = '<C-c>',
    exec = '<CR>',
    mark = 'x',
    confirm = '<CR>',
    in_select = true,
    whole_project = true,
  },
}

-- If there are multiple LSP servers attached to the current buffer, this function
-- will display the hover information from all of them.
-- Lspsaga only displays the hover information from the first LSP server.
local multi_lsp_hover = function()
  local hover = require('lspsaga.hover')

  if hover.preview_winid and api.nvim_win_is_valid(hover.preview_winid) then
    api.nvim_set_current_win(hover.preview_winid)
    return
  end

  if vim.bo.filetype == 'help' then
    api.nvim_feedkeys('K', 'ni', true)
    return
  end

  local params = util.make_position_params()
  local response = vim.lsp.buf_request_sync(0, 'textDocument/hover', params, 5000)
  local clients = vim.lsp.buf_get_clients()

  local value = ''

  if type(response.contents) == 'string' then
    value = value .. '\n' .. response.contents
  elseif response and #response > 0 then
    for i = 1, #response do
      if response[i] and response[i].result and response[i].result.contents then
        local result_contents = response[i].result.contents
        local more_lines = util.convert_input_to_markdown_lines(result_contents)
        util.trim_empty_lines(more_lines)
        if (#more_lines == 0) then return end

        local name = clients[i].name
        if name and #response > 1 then
          value = value .. '\n   \n------------------------------\n'
          value = '\n' .. value .. '\n    *** ' .. name .. ' ***\n'
          value = value .. '------------------------------\n'
        end

        value = value .. '\n' .. table.concat(more_lines, '\n') .. '  '
      end
    end
  end

  if value == '' then
    print('No hover available')
    return
  end

  local res = { value = value, kind = 'markdown', }
  hover:open_floating_preview(res)
end

-- Override the default hover function
require('lspsaga.hover').render_hover_doc = multi_lsp_hover

-- noremap = true,
local opts = { silent = true }
vim.keymap.set('n', '<Leader>er', '<Cmd>Lspsaga diagnostic_jump_next<CR>', opts)
vim.keymap.set('n', '<Leader>eu', '<Cmd>Lspsaga diagnostic_jump_prev<CR>', opts)
vim.keymap.set('n', 'K', '<Cmd>Lspsaga hover_doc<CR>', opts)
vim.keymap.set('n', 'gd', '<Cmd>Lspsaga lsp_finder<CR>', opts)
vim.keymap.set('n', 'gt', '<Cmd>Lspsaga goto_definition<CR>', opts)
vim.keymap.set('n', '<Leader>ca', '<Cmd>Lspsaga code_action<CR>', opts)
vim.keymap.set('n', 'gp', '<Cmd>Lspsaga peek_definition<CR>', opts)
vim.keymap.set('n', '<Leader>rn', '<Cmd>Lspsaga rename<CR>', opts)
vim.keymap.set('n', '<Leader>lo', '<Cmd>Lspsaga outline<CR>', opts)
vim.keymap.set('n', '""', '<Cmd>Lspsaga term_toggle<CR>', opts)
vim.keymap.set('t', '""', '<Cmd>Lspsaga term_toggle<CR>', opts)
