local utils = require('dimmer.utils')

_DimmerConfigurationValues = _DimmerConfigurationValues or {}

local config = {}
config.values = _DimmerConfigurationValues

local defaults = {
  -- TODO: probably want to add nvim-tree, nerdtree, chadtree..
  ft_ignore = { "netrw", "Outline", "undotree" },
  log_level = "debug"
}


function config.set_defaults(opts)
  config.values = vim.tbl_extend('force', opts or {}, defaults)
  config.values.ft_ignore = utils.set(config.values.ft_ignore)
end

config.set_defaults()

return config
