local state = require("dimmer").get_state()
local ui = require("dimmer.ui")
local M = {}

local function init_augroup()
  vim.cmd([[
    augroup DimPrototype
    au!
    au FileType * call setbufvar('%', 'ft', &ft)
    au WinEnter,VimEnter,FileType * call v:lua.require'dimmer.events'.handle_event('win_enter')
    au WinClosed * call v:lua.require'dimmer.events'.handle_event('win_close', expand('<afile>'))
    augroup END
  ]])
end

local function redraw(_, win_id, _, _, _)
  local overlay = state.overlays[win_id]
  if not overlay then
    return
  end
  ui.win_resize(win_id)
end


function M.init_events()
  init_augroup()

  local dimmer_nsid = vim.api.nvim_create_namespace("dimmer")
  vim.api.nvim_set_decoration_provider(dimmer_nsid, { on_win = redraw })
end

function M.handle_event(event, ...)
  -- really hate this shit
  -- wanna wrap this in a HOF or something
  if state.active then
    if event == "win_enter" then
      ui.win_enter()
    elseif event == "win_close" then
      ui.win_close(...)
    end
  end
end

return M
