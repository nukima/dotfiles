# ~/dotfiles/zsh/.zshrc

# 1. Initialize Starship
eval "$(starship init zsh)"

# 2. Initialize zoxide (smart cd)
eval "$(zoxide init zsh)"

# 3. Aliases (Data Engineering optimized)
alias ls="eza --icons --group-directories-first"
alias ll="eza -l --icons --group-directories-first"
alias cat="bat"
alias g="git"
alias k="kubectl" # If you use K8s
alias py="python3"

# 4. History Setup
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# 5. Load Plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# 6. FZF (Fuzzy Search) Setup
source <(fzf --zsh)
