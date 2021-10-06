# vim shell
shopt -s expand_aliases

# key unbind
if [[ -t 0  ]]; then
  stty stop undef
  stty start undef
fi


# user alias setting
alias ll='ls -alF'
alias la='ls -A'
alias lla='ls -lA'
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'


# user functions

# chmod expand
# use $1: path $2: file type $3 permission
function chmod-r(){
  find $1 -type $2 -exec chmod $3 {} +
}
