local config = require("dimmer.config")
local log_levels = {
  trace = "trace",
  debug = "debug",
  info = "info",
  warn = "warn",
  error = "error",
  fatal = "fatal",
}

return require("plenary.log").new({
  plugin = "dimmer",
  level = log_levels[config.values.log_level],
})
