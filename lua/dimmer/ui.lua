local utils = require("dimmer.utils")
local config = require("dimmer.config")
local log = require("dimmer.log")
local state = require("dimmer").get_state()

local M = {}
local winblend = "winblend"

function M.setup_highlight()
  log.trace("setup_highlight")
  local dim_color = config.values.debug and "#FAAEAE" or "None"
  require("dimmer.log").trace("setup_highlight - dim_color: " .. dim_color)
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

local function dim_window(win_id)
  vim.api.nvim_win_set_option(win_id, "winhighlight", "Normal:DimmerOverlay")
  vim.api.nvim_win_set_option(win_id, winblend, config.values.opacity)
  state.overlays[win_id].winblend = config.values.opacity
end

function M.create_overlay(win_id)
  log.trace("create_overlay")
  local window = {}
  window.config = M.win_config(win_id)
  window.buf_id = vim.api.nvim_create_buf(false, true)
  window.win_id = vim.api.nvim_open_win(window.buf_id, false, window.config)
  state.overlays[win_id] = window
  dim_window(window.win_id)
end

function M.destroy_overlay(win_id)
  log.trace("destroy_overlay")
  vim.api.nvim_win_close(win_id, false)
  state.overlays[win_id] = nil
end

local function undim_window(win_id)
  log.trace("undim_window")
  local overlay = state.overlays[win_id]
  if overlay then
    vim.api.nvim_win_set_option(overlay.win_id, winblend, 100)
  state.overlays[win_id].winblend = 100
  end
end

local function dim_others(win_id)
  log.trace("dim_other -win_id: " .. win_id)
  for overlay_id, _ in pairs(state.overlays) do
    if vim.api.nvim_win_get_option(overlay_id, "diff") then
    elseif overlay_id ~= win_id then
      dim_window(overlay_id)
    end
  end
end

function M.dim_windows()
  log.trace("dim_windws")
  local ft = vim.api.nvim_buf_get_var(0, "ft")
  local win_id = vim.api.nvim_get_current_win()

  if not state.overlays[win_id] then
    if vim.api.nvim_win_get_config(win_id)["relative"] == "" then
      M.create_overlay(win_id)
    end
  end

  undim_window(win_id)
  dim_others(win_id)
  if config.values.ft_ignore[ft] then
    -- TODO: un-dim windows
    return
  end
end

return M

--[[
:hi DimmerOverlay
DimmerOverlay  xxx gui=nocombine guibg=None

:hi ShadeOverlay
ShadeOverlay   xxx gui=nocombine guibg=None
]]
