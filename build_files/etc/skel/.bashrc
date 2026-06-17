[[ $- != *i* ]] && return

export EDITOR=nano
export VISUAL=nano
export HISTSIZE=5000
export HISTFILESIZE=10000

shopt -s histappend
shopt -s checkwinsize
shopt -s globstar

alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias h='history'
alias j='jobs -l'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ip='ip -color=auto'
alias diff='diff --color=auto'

if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

PS1='\[\e[38;5;39m\]\u\[\e[0m\]\[\e[38;5;248m\]@\[\e[0m\]\[\e[38;5;44m\]\h\[\e[0m\] \[\e[38;5;248m\]\w\[\e[0m\] \[\e[38;5;39m\]\$\[\e[0m\] '
