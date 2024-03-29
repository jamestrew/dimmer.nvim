local utils = require("dimmer.utils")

local config = {}
config.values = {}

local defaults = {
  -- TODO: probably want to add nvim-tree, nerdtree, chadtree..
  opacity = 50,
  dim_color = "None",
  ft_ignore = { "netrw", "Outline", "undotree" },
  log_level = "error",
  debug = false,
}

function config.set_defaults(opts)
  config.values = vim.tbl_extend("force", defaults, opts or {})
  config.values.ft_ignore = utils.set(config.values.ft_ignore)
end

config.set_defaults()

return config
