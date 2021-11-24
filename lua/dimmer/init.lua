local M = {}

local defaults = {
  ft_ignore = nil,
}

local function create_hl_groups()
  print("create_hl_groups -- TODO")
end

local function create_augroup(events, ft, func)
  ft = table.concat(ft or {}) ~= "" and ft or "*"
  local cmd = "autocmd "
    .. table.concat(events, ",")
    .. " "
    .. ft
    .. " "
    .. func
  print(cmd)
  vim.cmd("augroup Dim" .. events[1])
  vim.cmd("autocmd!")
  vim.cmd(cmd)
  vim.cmd("augroup END")
end

function M.win_enter(win_id)
  print("DIMMER win_enter - win_id: " .. win_id)
end

function M.setup(opts)
  print("DIMMER - setup")
  opts = vim.tbl_deep_extend("force", {}, defaults, opts or {})

  create_hl_groups()
  create_augroup(
    { "WinEnter", "VimEnter" },
    opts.ft_ignore,
    "call v:lua.require('dimmer').win_enter(win_getid())"
  )
end

return M
