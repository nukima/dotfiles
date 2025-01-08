-- This file contains the main configuration settings for WezTerm.
-- It includes settings for appearance, font, window behavior, and other preferences.

local wezterm = require 'wezterm'

local M = {}

function M.setup(config)
    config.adjust_window_size_when_changing_font_size = false
    config.automatically_reload_config = true
    config.color_scheme = 'PaleNightHC'
    config.enable_scroll_bar = true
    config.font = wezterm.font("Hack Nerd Font Mono", { weight = "Medium", stretch = "Expanded" })
    config.font_size = 12.0
    config.hide_tab_bar_if_only_one_tab = true
    config.initial_cols = 170
    config.initial_rows = 50
    config.enable_scroll_bar = true
    -- The leader is similar to how tmux defines a set of keys to hit in order to
    -- invoke tmux bindings. Binding to ctrl-a here to mimic tmux

    config.pane_focus_follows_mouse = false
    config.scrollback_lines = 5000
    config.use_dead_keys = false
    config.warn_about_missing_glyphs = false
    config.window_decorations = 'RESIZE'
    config.window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    }
    config.window_frame = {
        border_left_width = "0.28cell",
        border_right_width = "0.28cell",
        border_bottom_height = "0.15cell",
        border_top_height = "0.3cell",
    }
    config.window_background_image_hsb = {
        brightness = 0.02,
        hue = 1.0,
        saturation = 0.8,
    }
    config.window_background_opacity = 0.98
    -- config.window_background_image = utils.get_user_home() .. "/Pictures/Polygon-Wallpapers/4 - M7ZZrv8.jpg"
    config.window_background_image = "/home/manhnk/Pictures/Polygon-Wallpapers/4 - nNuRSqD.jpg"

    -- Tab bar
    config.use_fancy_tab_bar = true
    config.tab_bar_at_bottom = true
    config.switch_to_last_active_tab_when_closing_tab = true
    config.tab_max_width = 32
    config.colors = {
        tab_bar = {
            active_tab = {
                fg_color = '#073642',
                bg_color = '#2aa198',
            }
        }
    }

    -- Setup muxing by default
    config.unix_domains = {
        {
            name = 'unix',
        },
    }
    config.default_gui_startup_args = { 'connect', 'unix' }
end

return M