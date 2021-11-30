local config = require("dimmer.config")

local M = {}
local state = {}
state.overlays = {}
state.active = true

function M.setup(opts)
  config.set_defaults(opts)
  vim.api.nvim_set_keymap(
    "n",
    "<leader>od",
    ":lua require('dimmer.ui').create_overlay(vim.fn.win_getid())<CR>",
    {}
  )
  vim.api.nvim_set_keymap(
    "n",
    "<leader>cd",
    ":lua require('dimmer.ui').undim_window_all()<CR>",
    {}
  )

  require("dimmer.events").init_augroup()
  require("dimmer.ui").setup_highlight() -- TODO: standardize to init
  require("dimmer.log").trace("-- DIMMER INIT --")
end

function M.get_state()
  return state
end

function M.toggle()
  if state.active then
    vim.notify("dimmer.nvim disabled")
    state.active = false
  else
    vim.notify("dimmer.nvim enabled")
    state.active = true
  end
end

return M
