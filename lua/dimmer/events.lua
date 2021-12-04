local state = require("dimmer").get_state()
local ui = require("dimmer.ui")
local M = {}

function M.init_augroup()
  vim.cmd([[
    augroup DimPrototype
    au!
    au FileType * call setbufvar('%', 'ft', &ft)
    au WinEnter,VimEnter,FileType * call v:lua.require'dimmer.events'.handle_event('win_enter')
    au WinClosed * call v:lua.require'dimmer.events'.handle_event('win_close', expand('<afile>'))
    augroup END
  ]])
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
