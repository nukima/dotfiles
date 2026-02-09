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

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/nukima/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/nukima/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/nukima/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/nukima/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

