# WezTerm Configuration README

# Overview
This project contains a customized configuration for WezTerm, a terminal emulator. The configuration is organized into multiple Lua files for better maintainability and clarity. Each file serves a specific purpose, making it easier to manage key bindings, utility functions, event handling, and overall settings.

# Project Structure
The project is structured as follows:

```
wezterm-config
├── config
│   ├── keys.lua         # Contains key bindings for WezTerm
│   ├── utils.lua        # Includes utility functions used throughout the configuration
│   ├── events.lua       # Handles event bindings for WezTerm
│   └── settings.lua     # Contains main configuration settings for WezTerm
├── wezterm.lua          # Entry point for the WezTerm configuration
└── README.md            # Documentation for the project
```

# File Descriptions

## config/keys.lua
This file contains the key bindings for WezTerm. It includes custom key mappings for navigating between panes, resizing panes, managing tabs, and handling sessions. All relevant comments explaining the purpose of each key binding are preserved.

## config/utils.lua
This file includes utility functions used throughout the configuration. It contains functions like `get_user_home`, `pick_random_background`, and `get_background_folder`, along with comments explaining their functionality.

## config/events.lua
This file handles event bindings for WezTerm. It includes the session manager event bindings and the pane navigation events, with comments detailing the purpose of each event.

## config/settings.lua
This file contains the main configuration settings for WezTerm. It includes settings for appearance, font, window behavior, and other preferences, along with comments explaining each configuration option.

## wezterm.lua
This file serves as the entry point for the WezTerm configuration. It requires the other Lua files and integrates their functionality into the main configuration. It also includes comments that provide context for the overall configuration structure.

# Setup Instructions
1. Clone this repository to your local machine.
2. Ensure you have WezTerm installed.
3. Place the `wezterm.lua` file in your WezTerm configuration directory (usually `~/.config/wezterm/`).
4. The `config` directory contains all the necessary Lua files. Ensure they are in the same directory as `wezterm.lua`.
5. Launch WezTerm to see the custom configuration in action.

# Additional Notes
Feel free to modify the configuration files to suit your preferences. Each section is well-commented to help you understand the purpose of each setting and binding.