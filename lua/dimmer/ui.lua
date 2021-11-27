local config = require("dimmer.config")

local M = {}
local overlays = {}

function M.setup_highlight()
  local dim_color = config.values.debug and "#FAAEAE" or "None"
  vim.cmd("hi DimmerOverlay gui='nocombine' guibg=" .. dim_color)
end


function M.win_config(win_id)
  local win_info = vim.fn.getwininfo(win_id)[1]
  return {
    relative  = "editor",
    style     = "minimal",
    focusable = false,
    row    = win_info.winrow - 1,
    col    = win_info.wincol - 1,
    width  = win_info.width,
    height = win_info.height,
  }
end

function M.create_overlay(win_id)
  local window = {}
  window.config = M.win_config(win_id)
  window.buf_id = vim.api.nvim_create_buf(false, true)
  window.win_id = vim.api.nvim_open_win(window.buf_id, false, window.config)

  vim.api.nvim_win_set_option(win_id, "winhighlight", "Normal:DimmerOverlay")
  vim.api.nvim_win_set_option(win_id, "winblend", config.values.opacity)

  overlays[win_id] = window
end

return M
