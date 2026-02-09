# 🚀 Dotfiles: High-Productivity Data Engineer Setup

This repository contains my personal configuration for macOS. It focuses on **speed, automation, and a clean UI** for Data Engineering workflows.

## 🛠 Tech Stack
* **Shell**: Zsh + [Starship](https://starship.rs/)
* **Terminal**: iTerm2
* **Management**: GNU Stow & Homebrew

## 📂 Structure
```text
~/dotfiles/
├── Brewfile            # List of all installed apps/CLIs
├── zsh/
│   └── .zshrc          # Main shell configuration
├── starship/
│   └── .config/
│       └── starship.toml # Prompt visual config
├── git/
│   ├── .gitconfig      # Global config (Personal/SSH default)
│   └── .gitconfig-work # Work config (Force HTTPS/Masan email)
└── iterm/
    └── themes/         # Color schemes
```

## ⚡️ Quick Start
1.  **Clone Repo:**
    ```bash
    git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
    ```
2.  **Install Apps:**
    ```bash
    brew bundle --file=~/dotfiles/Brewfile
    ```
3.  **Apply Configs:**
    ```bash
    cd ~/dotfiles
    stow zsh starship git
    ```
