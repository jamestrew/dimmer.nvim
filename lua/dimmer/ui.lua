local utils = require("dimmer.utils")
local config = require("dimmer.config")
local log = require("dimmer.log")
local state = require("dimmer").get_state()

local M = {}
local WINBLEND = "winblend"
local WINHIGHLIGHT = "winhighlight"
local HI_DIMMER = "DimmerOverlay"

function M.setup_highlight()
  log.trace("setup_highlight")
  local dim_color = config.values.debug and "#FAAEAE" or "None"
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

---turn dimming on/off
---@param win_id number
---@param dim boolean
local function set_window_dim(win_id, dim)
  log.trace("set_window_dim: " .. (dim and "on" or "off"))
  local opacity = dim and config.values.opacity or 100
  local overlay = state.overlays[win_id]
  if overlay then
    vim.api.nvim_win_set_option(
      overlay.overlay_id,
      WINHIGHLIGHT,
      "Normal:" .. HI_DIMMER
    )
    vim.api.nvim_win_set_option(overlay.overlay_id, WINBLEND, opacity)
    state.overlays[win_id].winblend = opacity
  end
end

function M.create_overlay(win_id)
  log.trace("create_overlay")
  local window = {}
  window.config = M.win_config(win_id)
  window.buf_id = vim.api.nvim_create_buf(false, true)
  window.overlay_id = vim.api.nvim_open_win(window.buf_id, false, window.config)
  state.overlays[win_id] = window
  set_window_dim(win_id, true)
end

-- function M.destroy_overlay(win_id)
--   log.trace("destroy_overlay")
--   vim.api.nvim_win_close(win_id, false)
--   state.overlays[win_id] = nil
-- end

function M.undim_window_all()
  log.trace("undim_window_all")
  for win_id, _ in pairs(state.overlays) do
    set_window_dim(win_id, false)
  end
end

local function dim_others(win_id)
  log.trace("dim_other -win_id: " .. win_id)
  for alt_win_id, _ in pairs(state.overlays) do
    local bufnr = vim.api.nvim_win_get_buf(alt_win_id)
    local ft = vim.api.nvim_buf_get_var(bufnr, 'ft')
    if vim.api.nvim_win_get_option(alt_win_id, "diff") then
    elseif config.values.ft_ignore[ft] then
    elseif alt_win_id ~= win_id then
      set_window_dim(alt_win_id, true)
    end
  end
end

function M.win_enter()
  log.trace("win_enter")
  local win_id = vim.api.nvim_get_current_win()

  if not state.overlays[win_id] then
    if vim.api.nvim_win_get_config(win_id)["relative"] == "" then
      M.create_overlay(win_id)
    end
  end

  set_window_dim(win_id, false)
  dim_others(win_id)
  -- TODO: handle ft
  log.trace(vim.inspect(state.overlays))
end

return M
