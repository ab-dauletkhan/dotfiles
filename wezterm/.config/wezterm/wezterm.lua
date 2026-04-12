-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()


config.initial_cols = 120
config.initial_rows = 28
config.font_size = 16
config.color_scheme = 'Everforest Dark (Gogh)'

-- Finally, return the configuration to wezterm:
return config
