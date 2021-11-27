local log = require("dimmer.log")

local M = {}

local defaults = {
  ft_ignore = nil,
}

local function create_hl_groups()
  log.trace("create_hl_groups -- TODO")
end

local function create_augroup(events, ft, func)
  ft = table.concat(ft or {}) ~= "" and ft or "*"
  local cmd = "autocmd "
    .. table.concat(events, ",")
    .. " "
    .. ft
    .. " "
    .. func
  vim.cmd("augroup Dim" .. events[1])
  vim.cmd("autocmd!")
  vim.cmd(cmd)
  vim.cmd("augroup END")
end

function M.win_enter(win_id)
  log.trace("DIMMER win_enter - win_id: " .. win_id)
end

function M.setup(opts)
  config.set_defaults(opts)
  log.trace("DIMMER - setup")
  log.trace("config: " .. vim.inspect(config.values))

  create_hl_groups()
  create_augroup(
    { "WinEnter", "VimEnter" },
    opts.ft_ignore,
    "call v:lua.require('dimmer').win_enter(win_getid())"
  )
end

return M
