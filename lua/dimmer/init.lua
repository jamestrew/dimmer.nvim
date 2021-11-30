local config = require("dimmer.config")

local M = {}
local state = {}
state.overlays = {}
state.active = true

function M.setup(opts)
  config.set_defaults(opts)
  require("dimmer.events").init_augroup()
  require("dimmer.ui").init_highlight()
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
