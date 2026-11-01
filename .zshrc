# history (this is what the ghost text is based on)
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS

# tab completion
autoload -Uz compinit && compinit

# bash-like prompt
PROMPT='[%n@%m %~]$ '

# plugins (syntax-highlighting must stay last)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
