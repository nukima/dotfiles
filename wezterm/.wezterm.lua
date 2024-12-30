local wezterm = require 'wezterm'
local io = require("io")
local os = require("os")

local config = wezterm.config_builder()
local brightness = 0.03

-- Helper functions
local function get_user_home()
    return os.getenv("HOME")
end

local function get_background_folder()
    return get_user_home() .. "/Pictures/Polygon-Wallpapers"
end

local function pick_random_background(folder)
    local handle = io.popen('ls "' .. folder .. '"')
    if handle then
        local files = handle:read("*a")
        handle:close()

        local images = {}
        for file in string.gmatch(files, "[^\n]+") do
            table.insert(images, file)
        end

        if #images > 0 then
            return folder .. "/" .. images[math.random(#images)]
        end
    end
    return nil
end

-- Configuration settings
local function set_window_background_image_hsb()
    return {
        brightness = brightness,
        hue = 1.0,
        saturation = 0.8,
    }
end

local function set_window_padding()
    return {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    }
end

local function set_window_frame()
    return {
        border_left_width = "0.28cell",
        border_right_width = "0.28cell",
        border_bottom_height = "0.15cell",
        -- border_top_height = "0.3cell",
    }
end

local function set_keys()
    return {
        {
            key = "b",
            mods = "CTRL|SHIFT",
            action = wezterm.action_callback(function(window)
                local bg_image = pick_random_background(get_background_folder())
                if bg_image then
                    window:set_config_overrides({
                        window_background_image = bg_image,
                    })
                    wezterm.log_info("New bg:" .. bg_image)
                else
                    wezterm.log_error("Could not find bg image")
                end
            end),
        },
        {
            key = "L",
            mods = "CTRL|SHIFT",
            action = wezterm.action.OpenLinkAtMouseCursor,
        },
        {
            key = ">",
            mods = "CTRL|SHIFT",
            action = wezterm.action_callback(function(window)
                brightness = math.min(brightness + 0.01, 1.0)
                window:set_config_overrides({
                    window_background_image_hsb = set_window_background_image_hsb(),
                })
            end),
        },
        {
            key = "<",
            mods = "CTRL|SHIFT",
            action = wezterm.action_callback(function(window)
                brightness = math.max(brightness - 0.01, 0.01)
                window:set_config_overrides({
                    window_background_image_hsb = set_window_background_image_hsb(),
                })
            end),
        },
        {
            key = 'w',
            mods = 'CTRL',
            action = wezterm.action.CloseCurrentPane { confirm = false },
        },
    }
end

-- Apply configurations
config.window_background_image_hsb = set_window_background_image_hsb()
config.window_background_image = get_user_home() .. "/Pictures/Polygon-Wallpapers/1 - M7ZZrv8.jpg"
config.window_background_opacity = 0.96
config.macos_window_background_blur = 85
config.window_padding = set_window_padding()
config.color_scheme = "PaleNightHC"
config.font = wezterm.font("Hack Nerd Font Mono", { weight = "Medium", stretch = "Expanded" })
config.font_size = 12
config.window_decorations = "RESIZE"
config.enable_tab_bar = true
config.window_frame = set_window_frame()
config.keys = set_keys()
config.default_cursor_style = "SteadyBar"
config.cursor_thickness = 2
config.initial_cols = 140
config.initial_rows = 45
config.enable_scroll_bar = true

return config
