local wezterm = require 'wezterm'
local keys = require 'config.keys'
local settings = require 'config.settings'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

keys.setup(config)
settings.setup(config)

-- and finally, return the configuration to wezterm
return config