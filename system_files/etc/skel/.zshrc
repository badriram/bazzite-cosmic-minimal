# Bazzite COSMIC - Default zsh configuration
# Sensible defaults for an interactive shell

# ============================================================================
# HISTORY
# ============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS     # Don't record duplicates
setopt HIST_IGNORE_SPACE    # Don't record commands starting with space
setopt SHARE_HISTORY        # Share history between sessions
setopt APPEND_HISTORY       # Append to history file

# ============================================================================
# COMPLETION
# ============================================================================
autoload -Uz compinit
compinit

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Menu selection for completions
zstyle ':completion:*' menu select

# Completion colors
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Enable caching
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zsh/cache

# ============================================================================
# PROMPT
# ============================================================================
# Git-aware prompt with colors
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'
setopt PROMPT_SUBST
PROMPT='%F{cyan}%~%f${vcs_info_msg_0_} %F{white}%#%f '

# ============================================================================
# KEY BINDINGS
# ============================================================================
bindkey -e                    # Emacs key bindings
bindkey '^[[A' history-search-backward   # Up arrow searches history
bindkey '^[[B' history-search-forward    # Down arrow searches history
bindkey '^[[H' beginning-of-line         # Home
bindkey '^[[F' end-of-line               # End
bindkey '^[[3~' delete-char              # Delete

# ============================================================================
# ALIASES
# ============================================================================
# Modern replacements (if available)
if command -v eza &> /dev/null; then
  alias ls="eza --icons"
  alias ll="eza -l --icons"
  alias la="eza -la --icons"
  alias lt="eza --tree --icons"
else
  alias ll="ls -lh --color=auto"
  alias la="ls -lah --color=auto"
fi

command -v bat &>/dev/null && alias cat="bat --paging=never"

# Common shortcuts
alias ..="cd .."
alias ...="cd ../.."
alias grep="grep --color=auto"

# rpm-ostree shortcuts (immutable system)
alias ostree-install="rpm-ostree install"
alias ostree-remove="rpm-ostree uninstall"
alias ostree-status="rpm-ostree status"

# Flatpak shortcuts
alias fp="flatpak"
alias fps="flatpak search"
alias fpi="flatpak install"
alias fpr="flatpak run"

# Podman shortcuts
alias pd="podman"
alias pps="podman ps -a"
alias pimg="podman images"

# ============================================================================
# ENVIRONMENT
# ============================================================================
export EDITOR="${EDITOR:-nano}"
export VISUAL="${VISUAL:-nano}"

# Wayland clipboard (COSMIC default)
if command -v wl-copy &>/dev/null; then
  alias pbcopy="wl-copy"
  alias pbpaste="wl-paste"
fi

# ============================================================================
# OPTIONAL INTEGRATIONS
# ============================================================================
# fzf (if installed)
if command -v fzf &>/dev/null; then
  source <(fzf --zsh) 2>/dev/null || true
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
fi

# zoxide (if installed)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# Show system info on login (once per session)
if command -v fastfetch &>/dev/null && [[ -z "$_FASTFETCH_SHOWN" ]]; then
  export _FASTFETCH_SHOWN=1
  fastfetch --logo small 2>/dev/null || fastfetch
fi

# ============================================================================
# LOCAL OVERRIDES
# ============================================================================
# Source local config if it exists (for user customizations)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
