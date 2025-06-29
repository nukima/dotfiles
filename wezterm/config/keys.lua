-- This file contains the key bindings for WezTerm. It includes custom key mappings for navigating between panes, resizing panes, managing tabs, and handling sessions.
local os              = require 'os'
local wezterm         = require 'wezterm'
local session_manager = require 'wezterm-session-manager/session-manager'
local act             = wezterm.action
local mux             = wezterm.mux

local M = {}
-- --------------------------------------------------------------------
-- FUNCTIONS AND EVENT BINDINGS
-- --------------------------------------------------------------------

-- Session Manager event bindings
-- See https://github.com/danielcopper/wezterm-session-manager
wezterm.on("save_session", function(window) session_manager.save_state(window) end)
wezterm.on("load_session", function(window) session_manager.load_state(window) end)
wezterm.on("restore_session", function(window) session_manager.restore_state(window) end)

-- Wezterm <-> nvim pane navigation
-- You will need to install https://github.com/aca/wezterm.nvim
-- and ensure you export NVIM_LISTEN_ADDRESS per the README in that repo

local move_around = function(window, pane, direction_wez, direction_nvim)
    local result = os.execute("env NVIM_LISTEN_ADDRESS=/tmp/nvim" .. pane:pane_id() .. " " .. wezterm.home_dir .. "/go/bin/wezterm.nvim.navigator" .. " " .. direction_nvim)
    if result then
		window:perform_action(
            act({ SendString = "\x17" .. direction_nvim }),
            pane
        )
    else
        window:perform_action(
            act({ ActivatePaneDirection = direction_wez }),
            pane
        )
    end
end

local function get_user_home()
    return os.getenv("HOME")
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

local function get_background_folder()
    return get_user_home() .. "/Pictures/Polygon-Wallpapers"
end

wezterm.on("move-left", function(window, pane)
	move_around(window, pane, "Left", "h")
end)

wezterm.on("move-right", function(window, pane)
	move_around(window, pane, "Right", "l")
end)

wezterm.on("move-up", function(window, pane)
	move_around(window, pane, "Up", "k")
end)

wezterm.on("move-down", function(window, pane)
	move_around(window, pane, "Down", "j")
end)

local vim_resize = function(window, pane, direction_wez, direction_nvim)
	local result = os.execute(
		"env NVIM_LISTEN_ADDRESS=/tmp/nvim"
			.. pane:pane_id()
			.. " "
            .. wezterm.home_dir
			.. "/.local/bin/wezterm.nvim.navigator"
			.. " "
			.. direction_nvim
	)
	if result then
		window:perform_action(act({ SendString = "\x1b" .. direction_nvim }), pane)
    else
        window:perform_action(act({ AdjustPaneSize = { direction_wez, 1 } }), pane)
	end
end

wezterm.on("resize-left", function(window, pane)
	vim_resize(window, pane, "Left", "h")
end)

wezterm.on("resize-right", function(window, pane)
	vim_resize(window, pane, "Right", "l")
end)

wezterm.on("resize-up", function(window, pane)
	vim_resize(window, pane, "Up", "k")
end)

wezterm.on("resize-down", function(window, pane)
	vim_resize(window, pane, "Down", "j")
end)

function M.setup(config)
    config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 2000 }
    config.mouse_bindings = {
        -- Open URLs with Ctrl+Click
        {
            event = { Up = { streak = 1, button = 'Left' } },
            mods = 'CTRL',
            action = wezterm.action.OpenLinkAtMouseCursor,
        }
    }
    config.keys = {
        -- -- Disable Alt-Enter combination (already used in tmux to split pane)
        -- {
        --     key = 'Enter',
        --     mods = 'ALT',
        --     action = act.DisableDefaultAssignment,
        -- },
    
        -- ----------------------------------------------------------------
        -- Change background image
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
    
        -- Copy mode
        {
            key = '[',
            mods = 'LEADER',
            action = act.ActivateCopyMode,
        },
    
        -- ----------------------------------------------------------------
        -- TABS
        --
        -- Where possible, I'm using the same combinations as I would in tmux
        -- ----------------------------------------------------------------
    
        -- Show tab navigator; similar to listing panes in tmux
        {
            key = 'w',
            mods = 'LEADER',
            action = act.ShowTabNavigator,
        },
        -- Create a tab (alternative to Ctrl-Shift-Tab)
        {
            key = 'c',
            mods = 'LEADER',
            action = act.SpawnTab 'CurrentPaneDomain',
        },
        -- Rename current tab; analagous to command in tmux
        {
            key = ',',
            mods = 'LEADER',
            action = act.PromptInputLine {
                description = 'Enter new name for tab',
                action = wezterm.action_callback(
                    function(window, pane, line)
                        if line then
                            window:active_tab():set_title(line)
                        end
                    end
                ),
            },
        },
        -- Move to next/previous TAB
        {
            key = 'n',
            mods = 'LEADER',
            action = act.ActivateTabRelative(1),
        },
        {
            key = 'p',
            mods = 'LEADER',
            action = act.ActivateTabRelative(-1),
        },
        -- Close tab
        {
            key = '&',
            mods = 'LEADER|SHIFT',
            action = act.CloseCurrentTab{ confirm = true },
        },
    
        -- ----------------------------------------------------------------
        -- PANES
        --
        -- These are great and get me most of the way to replacing tmux
        -- entirely, particularly as you can use "wezterm ssh" to ssh to another
        -- server, and still retain Wezterm as your terminal there.
        -- ----------------------------------------------------------------
    
        -- -- Vertical split
        {
            -- |
            key = '|',
            mods = 'LEADER|SHIFT',
            action = act.SplitPane {
                direction = 'Right',
                size = { Percent = 50 },
            },
        },
        -- Horizontal split
        {
            -- -
            key = '-',
            mods = 'LEADER',
            action = act.SplitPane {
                direction = 'Down',
                size = { Percent = 50 },
            },
        },
        -- CTRL + (h,j,k,l) to move between panes
        {
            key = 'h',
            mods = 'CTRL',
            action = act({ EmitEvent = "move-left" }),
        },
        {
            key = 'j',
            mods = 'CTRL',
            action = act({ EmitEvent = "move-down" }),
        },
        {
            key = 'k',
            mods = 'CTRL',
            action = act({ EmitEvent = "move-up" }),
        },
        {
            key = 'l',
            mods = 'CTRL',
            action = act({ EmitEvent = "move-right" }),
        },
        -- ALT + (h,j,k,l) to resize panes
        {
            key = 'h',
            mods = 'ALT',
            action = act({ EmitEvent = "resize-left" }),
        },
        {
            key = 'j',
            mods = 'ALT',
            action = act({ EmitEvent = "resize-down" }),
        },
        {
            key = 'k',
            mods = 'ALT',
            action = act({ EmitEvent = "resize-up" }),
        },
        {
            key = 'l',
            mods = 'ALT',
            action = act({ EmitEvent = "resize-right" }),
        },
        -- Close/kill active pane
        {
            key = 'x',
            mods = 'LEADER',
            action = act.CloseCurrentPane { confirm = true },
        },
        -- Swap active pane with another one
        {
            key = '{',
            mods = 'LEADER|SHIFT',
            action = act.PaneSelect { mode = "SwapWithActiveKeepFocus" },
        },
        -- Zoom current pane (toggle)
        {
            key = 'z',
            mods = 'LEADER',
            action = act.TogglePaneZoomState,
        },
        {
            key = 'f',
            mods = 'ALT',
            action = act.TogglePaneZoomState,
        },
        -- Move to next/previous pane
        {
            key = ';',
            mods = 'LEADER',
            action = act.ActivatePaneDirection('Prev'),
        },
        {
            key = 'o',
            mods = 'LEADER',
            action = act.ActivatePaneDirection('Next'),
        },
    
        -- ----------------------------------------------------------------
        -- Workspaces
        --
        -- These are roughly equivalent to tmux sessions.
        -- ----------------------------------------------------------------
    
        -- Attach to muxer
        {
            key = 'a',
            mods = 'LEADER',
            action = act.AttachDomain 'unix',
        },
    
        -- Detach from muxer
        {
            key = 'd',
            mods = 'LEADER',
            action = act.DetachDomain { DomainName = 'unix' },
        },
    
        -- Show list of workspaces
        {
            key = 's',
            mods = 'LEADER',
            action = act.ShowLauncherArgs { flags = 'WORKSPACES' },
        },
        -- Rename current session; analagous to command in tmux
        {
            key = '$',
            mods = 'LEADER|SHIFT',
            action = act.PromptInputLine {
                description = 'Enter new name for session',
                action = wezterm.action_callback(
                    function(window, pane, line)
                        if line then
                            mux.rename_workspace(
                                window:mux_window():get_workspace(),
                                line
                            )
                        end
                    end
                ),
            },
        },
    
        -- Session manager bindings
        {
            key = 's',
            mods = 'LEADER|SHIFT',
            action = act({ EmitEvent = "save_session" }),
        },
        {
            key = 'L',
            mods = 'LEADER|SHIFT',
            action = act({ EmitEvent = "load_session" }),
        },
        {
            key = 'R',
            mods = 'LEADER|SHIFT',
            action = act({ EmitEvent = "restore_session" }),
        },
    }
end

return M