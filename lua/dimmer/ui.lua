local config = require("dimmer.config")
local log = require("dimmer.log")
local state = require("dimmer").get_state()

local M = {}
local WINBLEND = "winblend"
local WINHIGHLIGHT = "winhighlight"
local HI_DIMMER = "DimmerOverlay"

---turn dimming on/off
---@param win_id number
---@param dim boolean
local function set_window_dim(win_id, dim)
  log.trace("set_window_dim: " .. (dim and "on" or "off"))
  local opacity = dim and (100 - config.values.opacity) or 100
  local overlay = state.overlays[win_id]
  if overlay then
    vim.api.nvim_win_set_option(
      overlay.overlay_id,
      WINHIGHLIGHT,
      "Normal:" .. HI_DIMMER
    )
    vim.api.nvim_win_set_option(overlay.overlay_id, WINBLEND, opacity)
    state.overlays[win_id].winblend = dim and opacity or 0
  end
end

local function valid_window(win_id, alt_win_id)
  local bufnr_ok, bufnr = pcall(vim.api.nvim_win_get_buf, alt_win_id)
  if bufnr_ok then
    local ft_ok, ft = pcall(vim.api.nvim_buf_get_var, bufnr, "ft")
    if ft_ok then
      if
        not vim.api.nvim_win_get_option(alt_win_id, "diff")
        and not config.values.ft_ignore[ft]
        and alt_win_id ~= win_id
      then
        return true, "dimming"
      else
        return false, "skipping"
      end
    else
      return false, "ft not set"
    end
  else
    return false, "bufnr does not exist"
  end
end

local function dim_others(win_id)
  for alt_win_id, _ in pairs(state.overlays) do
    local valid, msg = valid_window(win_id, alt_win_id)
    if valid then
      set_window_dim(alt_win_id, true)
    end
    log.trace("dim_others win_id: " .. alt_win_id .. " msg: " .. tostring(msg))
  end
end

local function window_exists(win_id)
  for _, windows in ipairs(vim.fn.getwininfo()) do
    if windows.winid == win_id then
      return true
    end
  end
  return false
end

local function create_overlay(win_id)
  if state.overlays[win_id] and window_exists(win_id) then
    return
  end

  if vim.api.nvim_win_get_config(win_id)["relative"] == "" then
    local window = {}
    window.config = M.win_config(win_id)
    window.buf_id = vim.api.nvim_create_buf(false, true)
    window.overlay_id = vim.api.nvim_open_win(
      window.buf_id,
      false,
      window.config
    )

    log.trace(
      "create_overlay win_id: " .. win_id .. "overlay_id: " .. window.overlay_id
    )
    state.overlays[win_id] = window
    set_window_dim(win_id, true)
  end
end

local function get_overlayed_win_id(overlay_id)
  for win_id, window in pairs(state.overlays) do
    if window.overlay_id == overlay_id then
      return win_id
    end
  end
  return -1
end

function M.init_highlight()
  log.trace("init_highlight")
  local dim_color = config.values.debug and "#FAAEAE" or config.values.dim_color
  vim.cmd("hi " .. HI_DIMMER .. " gui='nocombine' guibg=" .. dim_color)
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

function M.undim_window_all()
  log.trace("undim_window_all")
  for win_id, _ in pairs(state.overlays) do
    set_window_dim(win_id, false)
  end
end

function M.win_enter()
  log.trace("win_enter")
  local win_id = vim.api.nvim_get_current_win()

  create_overlay(win_id)
  set_window_dim(win_id, false)
  dim_others(win_id)
end

function M.win_close(win_id)
  win_id = tonumber(win_id)
  local overlay = state.overlays[win_id]
  if overlay == nil then
    log.trace("win_close - no overlay win_id: " .. win_id)
    local overlayed_id = get_overlayed_win_id(win_id)
    if overlayed_id ~= -1 then
      create_overlay(overlayed_id)
    end
  else
    vim.api.nvim_win_close(overlay.overlay_id, false)
    log.trace(
      "win_close - overlay closed win_id: "
        .. win_id
        .. "overlay_id: "
        .. overlay.overlay_id
    )
    state.overlays[win_id] = nil
  end
end

return M
