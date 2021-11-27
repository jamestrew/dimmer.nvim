local config = require("dimmer.config")

local M = {}

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
  require("dimmer.events").init_augroup()
  require("dimmer.ui").setup_highlight()
end

return M
