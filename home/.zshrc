function source_if_exists () {
  FILE=$1 && test -e $FILE && source $FILE
}

export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/opt:$PATH"
export PATH="$HOME/.local/bin:$PATH"

export XDG_CONFIG_HOME="$HOME/.config"

# -----------------------------------------------------------------------------
#                               Local Configs
# -----------------------------------------------------------------------------
source_if_exists "$HOME/.config/zsh/local.zsh"

# Add some colors
alias ls="ls --color=auto"
alias grep="grep --color=auto"

# -----------------------------------------------------------------------------
#                              Shell settings
# -----------------------------------------------------------------------------
# tab-complete hidden items
_comp_options+=(globdots)
# editor
if [ -x "$(command -v nvim)" ]; then
  export EDITOR=nvim
else
  export EDITOR=vim
fi

# -----------------------------------------------------------------------------
#                                App settings
# -----------------------------------------------------------------------------
# fzf
source_if_exists "$HOME/.config/fzf/completion.zsh"
source_if_exists "$HOME/.config/fzf/key-bindings.zsh"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zsh
if [ -z "$ZSH_SET" ]; then
  export ZSH_PLUGINS_DIR="/usr/share"
  export ZSH_USER_PLUGINS_DIR="$HOME/.local/share/zsh"

  zsh_syntax_highlighting="zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  if [ -f "$ZSH_PLUGINS_DIR/$zsh_syntax_highlighting" ]; then
    source "$ZSH_PLUGINS_DIR/$zsh_syntax_highlighting"
  elif [ -f "$ZSH_USER_PLUGINS_DIR/$zsh_syntax_highlighting" ]; then
    source "$ZSH_USER_PLUGINS_DIR/$zsh_syntax_highlighting"
  fi

  zsh_autosuggestions="$ZSH_USER_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
  zsh_autosuggestions="zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  if [ -f "$ZSH_PLUGINS_DIR/$zsh_autosuggestions" ]; then
    source "$ZSH_PLUGINS_DIR/$zsh_autosuggestions"
  elif [ -f "$ZSH_USER_PLUGINS_DIR/$zsh_autosuggestions" ]; then
    source "$ZSH_USER_PLUGINS_DIR/$zsh_autosuggestions"
  fi

  if [ -d "$ZSH_USER_PLUGINS_DIR/zsh-completions/src" ]; then
    fpath=("$ZSH_USER_PLUGINS_DIR/zsh-completions/src" $fpath)
  fi
  bindkey '^Y' autosuggest-accept
  export ZSH_SET=1
fi

HISTFILE=~/.local/share/zsh/.history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/default.toml"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/large_repo.toml"
if [[ "$SHELL" = *zsh ]]; then
  # Starship: https://github.com/starship/starship
  if [ -x "$(command -v starship)" ]; then
    eval "$(starship init zsh)"
  else
    precmd() { print "" }
    export PS1="%{%F{blue}%}%3~"$'\n'"> %{%f%}% "
  fi
fi

# Keep scrollback buffer when typing clear
alias clear="clear -x"
# Enable vi-mode
bindkey -v

[ -x "$(command -v direnv)" ] && eval "$(direnv hook zsh)"
[ -x "$(command -v fdfind)" ] && alias fd="fdfind"

function gpath() {
  if [ -x "$(command -v xclip)" ] && cat /proc/version | grep -q "WSL" ; then
    wslpath -w "$PWD" | xclip -selection clipboard
  else
    pwd | xclip -selection clipboard
  fi
}

alias git-zip='git archive --format zip -o "$(basename $PWD).zip" HEAD'
alias du-list='du -sh * | sort -rh'
[ -x "$(command -v nvim)" ] && alias vim=nvim

if [[ $(uname) == "Darwin" ]]; then
  source_if_exists "$HOME/.config/zsh/darwin.zsh"
elif [[ "$(cat /proc/sys/kernel/osrelease)" == *"WSL2" ]]; then
  source_if_exists "$HOME/.config/zsh/wsl2.zsh"
fi

function enable_sdkman() {
  export SDKMAN_DIR="$HOME/.sdkman"
  [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
}

function enable_nvm() {
  export NVM_DIR="$HOME/.config/nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}
