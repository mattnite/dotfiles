ZSH_THEME="matt"
export ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh
plugins=(git vi-mode)

# my environment variables
export EDITOR=nvim
export XDG_CONFIG_HOME=/home/mknight/.config

set -o magicequalsubst
alias vim=nvim
alias vi=nvim

export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
