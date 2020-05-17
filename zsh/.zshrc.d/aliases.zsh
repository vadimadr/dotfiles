# enable fasd pruductivity booster
eval "$(fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install)"

alias mkdir='mkdir -pv'
alias grep="grep --color=auto"
alias g="git"
alias go="git checkout"

alias ss=subl
alias v=vim

alias xc=xclip

alias ls="ls --color=auto"
alias ll="ls -lhv --group-directories-first"
alias l=ll
alias dl="ll -d */"
alias d=dl

alias df="df -h | head -n1 && df -h | sed '1d' | sort -k1"
function ds() {echo "$(pwd) - $(du -sh 2>/dev/null | awk '{print $1}') used";} # diectory size

alias pmem="ps -o pid,rss,pmem,args -e --sort -rss"
function pmem10() { pmem | awk '{print substr($0,0,100)}' | head -10;}
alias pcpu="ps -o pid,pcpu,args -e --sort -pcpu"
function pcpu10() {pcpu | awk '{print substr($0,0,100)}' | head -10; }

alias cd..="cd .."
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# show directory stack
alias cdd="dirs -v" 
alias cd-="dirs -v"

# Apt aliases
alias apti='sudo apt install'
alias aptr='sudo apt remove'
alias apts='apt-cache search'
alias aptf='apt-file search'
alias aptu='sudo apt update'
alias aptup='sudo apt upgrade'

function aptp() { sudo add-apt-repository "$@" && sudo apt-get update;}


alias tarx="tar -xzvf"
alias tarx="tar xzvf"
alias tart="tar tzvf"
alias xx=aunpack
# extract () {
#    if [ -f $1 ] ; then
#        case $1 in
#            *.tar.bz2)   tar xvjf $1    ;;
#            *.tar.gz)    tar xvzf $1    ;;
#            *.tgz)	    tar xvzf $1    ;;
#            *.bz2)       bunzip2 $1     ;;
#            *.rar)       unrar x $1       ;;
#            *.gz)        gunzip $1      ;;
#            *.tar)       tar xvf $1     ;;
#            *.tbz2)      tar xvjf $1    ;;
#            *.tgz)       tar xvzf $1    ;;
#            *.zip)       unzip $1       ;;
#            *.Z)         uncompress $1  ;;
#            *.7z)        7z x $1        ;;
#            *)           echo "don't know how to extract '$1'..." ;;
#        esac
#    else
#        echo "'$1' is not a valid file!"
#    fi
#  }

 cdm () {
  mkdir -p $1 && cd $1
 }

 gotmp() {
 # tmpname=$(python -c 'import random,sys; sys.stdout.write(hex(random.getrandbits(64))[2:-1]+"\n")' 2>/dev/null)


 if [[ -n $1 && -n $(ls /tmp | grep "workdir-.*$1") ]]; then
    for wd in /tmp/workdir-*$1; do
     if [[ -d $wd ]]; then
       echo "Going to: $wd"
       cd $wd
       return
     fi
    done 
 fi

 tmpname=$(date +'%m%d-%H%M')
 # dlist=$(find /tmp -type d -name "workdfir-${tmpname}*" 2>/dev/null)
 if [[ -n $1 ]]; then
 	tmpname="${tmpname}-$1"
 fi
 mkdir "/tmp/workdir-$tmpname"
 cd "/tmp/workdir-$tmpname"
 }


alias sudo="sudo "
alias s="sudo "
alias sd="sudo "

alias gpp="g++-5 -std=c++14"
alias gcc="gcc-5"
function ubb() { make && ./ub $@ }
function myip() { wget -O - -q http://icanhazip.com }
alias -g DN="2>/dev/null"

alias cpr='rsync -r --info=progress2 --human-readable --no-i-r -a'
function mvr() { cpr --remove-source-files $1 $2 && rm -rf $1 }

alias py=ipython
alias ipy="ipython"
alias pyqt="ipy qtconsole"
alias ipyex='xclip -selection c -o > /tmp/jupyter_connection_info.json; ipython qtconsole --existing /tmp/jupyter_connection_info.json'

alias pdb="python3 -m ipdb"

function venv() {. `find ! -path '*/.tox/*' -a -wholename '*/bin/activate'`}

alias pl="perl -lan"
alias pp="pl -E "
alias psed="pl -pE"

alias xclip="xclip -sel clip"
function gist() {
  local long=`/usr/local/bin/gist -p $1`
  local short=`py -c "import requests as r; print(r.post('https://git.io/', data={'url':'$long'}).headers['location'])"`
  echo full: $long
  echo short: $short
  echo copied to clipboard
  echo $short | xclip
}

function ff() {
  find -name "*$1*"
}

function copy_path() {
  path_=`realpath $1`
  echo $path_ | xclip
  echo Copied to clipboard:
  echo $path_
}

alias llc=copy_path

alias md5=md5sum
alias sha1=sha1sum
alias sha256=sha256sum
alias sha512=sha512sum

alias wh=which
alias ww=which
alias gg=grep
alias gr=grep
alias stat=/usr/bin/stat

alias sd='s systemctl'
alias dcmp='docker-compose'
alias r='source /home/vadim/.virtualenvs/py36/bin/ranger'
alias wo=workon

function _patch_path_var() {
  _var_name=$1
  _new_path=$2

  new_value="${(P)_var_name}:$(realpath $_new_path)" 
  # Replace consecutive :, : at the begging and end of line
  new_value=$( echo $new_value | sed -r -e 's/:+/:/g' -e 's/(^:)|(:$)//g' )

  export $_var_name=$new_value

  # Output modified variable
  echo "$_var_name: "
  echo "${(P)_var_name}" | sed 's/:/\n/g'
}

alias py_path='_patch_path_var PYTHONPATH'
alias lib_path='_patch_path_var LD_LIBRARY_PATH'
alias exe_path='_patch_path_var PATH'

fuck () {
    TF_PYTHONIOENCODING=$PYTHONIOENCODING;
    export TF_SHELL=zsh;
    export TF_ALIAS=fuck;
    TF_SHELL_ALIASES=$(alias);
    export TF_SHELL_ALIASES;
    TF_HISTORY="$(fc -ln -10)";
    export TF_HISTORY;
    export PYTHONIOENCODING=utf-8;
    TF_CMD=$(
        thefuck THEFUCK_ARGUMENT_PLACEHOLDER $@
    ) && eval $TF_CMD;
    unset TF_HISTORY;
    export PYTHONIOENCODING=$TF_PYTHONIOENCODING;
    test -n "$TF_CMD" && print -s $TF_CMD
}