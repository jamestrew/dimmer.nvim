local ui = require('dimmer.ui')
local config = require("dimmer.config")

local M = {}

_DimmerWindowIDs = _DimmerWindowIDs or {}

local function create_hl_groups()
  require("dimmer.log").trace("create_hl_groups -- TODO")
end

local function augroup_prototype()
  vim.cmd([[
    augroup DimPrototype
    au!
    au FileType * call setbufvar('%', 'ft', &ft)
    au WinEnter,VimEnter,FileType * call v:lua.require('dimmer').autocmd_prototype(getbufvar('%', 'ft'))
    augroup END
  ]])
end

function M.autocmd_prototype(ft)
  if config.values.ft_ignore[ft] then
    -- TODO: not skip but actually undo the dimmer for this window
    require("dimmer.log").trace("DIMMER autocmd_prototype - skipped")
    return
  end
  local win_id = vim.api.nvim_get_current_win()
  require("dimmer.log").trace(
    "DIMMER autocmd_prototype - win: " .. win_id .. " ft: " .. ft
  )
end

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
    ":lua require('dimmer.ui').destroy_overlay(",
    {}
  )
  require("dimmer.ui").setup_highlight()

  augroup_prototype()
  -- create_hl_groups()
  -- local call_dimmer = "call v:lua.require('dimmer')."
  -- create_augroup({ "FileType" }, call_dimmer .. "new_window(win_getid())")
  -- create_augroup(
  --   { "WinEnter", "VimEnter" },
  --   call_dimmer .. "win_enter(win_getid(), &ft)"
  -- )
end

return M
