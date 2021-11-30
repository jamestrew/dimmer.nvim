local config = require("dimmer.config")
local M = {}

function M.init_augroup()
  vim.cmd([[
    augroup DimPrototype
    au!
    au FileType * call setbufvar('%', 'ft', &ft)
    au WinEnter,VimEnter,FileType * call v:lua.require('dimmer.ui').win_enter()
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

return M
