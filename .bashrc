#!/bin/bash

# This is from Manjaro

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
	else
		PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
	fi

	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

unset use_color safe_term match_lhs sh

## End Manjaro Stuff


# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# From https://gist.github.com/zachbrowne/8bc414c9f30192067831fafebd14255c
# Expand the history size
export HISTFILESIZE=10000
export HISTSIZE=500

# Don't put duplicate lines in the history 
export HISTCONTROL=erasedups:ignoredups

shopt -s checkwinsize

# if you start a new terminal, you have old session history
shopt -s histappend
export EDITOR=nano

export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'



export PATH="$PATH:~/.local/bin"
export LESS=-R

_help(){
	echo -e -n '\033[1m'
	echo -n Aliases
	echo -e '\033[0m'
	alias

	echo -e -n '\033[1m'
	echo -n Bash
	echo -e '\033[0m'
	builtin help
}

_help2(){
	if [ -z "$1" ]; then
		_help | less
	else
		builtin help $1 $2 $3 $4
	fi
}

alias help="_help2"

cd(){
	builtin cd $1
	echo -e -n '\033[1m'
	echo -n $PWD
	echo -e -n '\033[0m'
	echo
	ls -alh | head -n 5
}

#alias cd='_cd'

alias ls='ls -alh --color=auto'
alias ..='cd ..'

alias trash='mv --force -t ~/.local/share/Trash '

alias df="df -h"

# c command: Quick easy to access calculator.
# Usage: 
# c 2+3
# c 2kg to in

_calc_with_units () { 
  set -o noglob; 
  X=$(echo $* | sed "s/\([0-9]*\)C /tempC(\1) /gI")
  X=$(echo $X | sed "s/\([0-9]*\)F /tempF(\1) /gI")
  X=$(echo $X | sed "s/to F$/to tempF/gI")
  X=$(echo $X | sed "s/to C$/to tempC/gI")

  units --terse --compact "$(echo $X|sed 's/ to .*//')" $(echo $X|sed -n -e 's/^.* to //p'); 
  set +o noglob;
}
alias c='set -o noglob;_calc_with_units'


# hex command
# Usage: hex 65535

# Outputs:

# Dec: 65535
# Hex: 0xFFFF
# Bin: 0b1111111111111111

_hex () { 
  set -o noglob;
  python -c "print(f'Dec: {($*)}')"; 
  python -c "import math;v=($*);l=int(math.log2(v)/8)+1;h='0x{0:0{1}X}'.format(v,l*2);print(f'Hex: {h}')"; 
  python -c "import math;v=($*);l=int(math.log2(v)/8)+1;b=format(v, '0'+str(l*8)+'b');print(f'Bin: 0b{b}')"; 
  set +o noglob;
}

alias hex='set -o noglob;_hex'

# Quickly edit bashrc, then source it.
alias bashrc="nano ~/.bashrc; source ~/.bashrc"

# Activate  the virtual environment for the dir you are currently in
alias venv='source .venv/bin/activate;'

