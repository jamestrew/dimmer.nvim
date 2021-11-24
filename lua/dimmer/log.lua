local log_levels = {"trace", "debug", "info", "warn", "error", "fatal"}

-- TODO: get log level from opts


return require("plenary.log").new({
  plugin = "dimmer",
  level = "trace",
})
