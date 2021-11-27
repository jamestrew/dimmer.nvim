local config = require("dimmer.config")
local log = require("dimmer.log")

local M = {}
M.overlays = {}

function M.setup_highlight()
  -- log.trace("DIMMER setup_highlight")
  local dim_color = config.values.debug and "#FAAEAE" or "None"
  require("dimmer.log").trace(
    "DIMMER setup_highlight - dim_color: " .. dim_color
  )
  vim.cmd("hi DimmerOverlay gui='nocombine' guibg=" .. dim_color)

  local exists, _ = pcall(function()
    return vim.api.nvim_get_hl_by_name("DimmerBrightnessPopup", false)
  end)
  if not exists then
    vim.api.nvim_command("highlight link DimmerBrightnessPopup Number")
  end
end

function M.win_config(win_id)
  local win_info = vim.fn.getwininfo(win_id)[1]
  return {
    relative = "editor",
    style = "minimal",
    focusable = false,
    row = win_info.winrow - 1,
    col = win_info.wincol - 1,
    width = win_info.width,
    height = win_info.height,
  }
end

function M.create_overlay(win_id)
  local window = {}
  window.config = M.win_config(win_id)
  window.buf_id = vim.api.nvim_create_buf(false, true)
  window.win_id = vim.api.nvim_open_win(window.buf_id, false, window.config)

  vim.api.nvim_win_set_option(
    window.win_id,
    "winhighlight",
    "Normal:DimmerOverlay"
  )
  vim.api.nvim_win_set_option(window.win_id, "winblend", config.values.opacity)

  log.trace(
    "DIMMER create_overlay - win_id: "
      .. win_id
      .. " overlay_id: "
      .. window.win_id
  )
  M.overlays[win_id] = window
end

function M.destroy_overlay(win_id)
  vim.api.nvim_win_close(win_id, false)
  M.overlays[win_id] = nil
end

return M

--[[
:hi DimmerOverlay
DimmerOverlay  xxx gui=nocombine guibg=None

:hi ShadeOverlay
ShadeOverlay   xxx gui=nocombine guibg=None
]]
