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

# Synthwave prompt: user (magenta) @ host (purple)  path (cyan)  $ (magenta)
PS1='\[\e[38;2;255;45;149m\]\u\[\e[0m\]\[\e[38;2;64;64;128m\]@\[\e[0m\]\[\e[38;2;185;103;255m\]\h\[\e[0m\] \[\e[38;2;0;240;255m\]\w\[\e[0m\] \[\e[38;2;255;45;149m\]\$\[\e[0m\] '

# Synthwave login banner
if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi
