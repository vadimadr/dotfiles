# Setup virtualenv wrapper
# WORKON_HOME=$HOME/.virtualenvs
# VIRTUALENVWRAPPER_SCRIPT=$HOME/.local/bin/virtualenvwrapper.sh
# VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
# VIRTUALENVWRAPPER_VIRTUALENV=$HOME/.local/bin/virtualenv
# source $HOME/.local/bin/virtualenvwrapper_lazy.sh

# Init default virtual env
# Do not execute python scripts at zsh init! Init env manually
# DEFAULT_VIRTUAL_ENV=py36
# PATH="$WORKON_HOME/$DEFAULT_VIRTUAL_ENV/bin:$PATH"
# VIRTUALENVWRAPPER_PROJECT_FILENAME=.project
# VIRTUALENVWRAPPER_WORKON_CD=1
# VIRTUALENVWRAPPER_HOOK_DIR=/home/vadim/.virtualenvs
# VIRTUAL_ENV=/home/vadim/.virtualenvs/py36

# CUDA_HOME=/usr/local/cuda
# LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/cuda/lib64"

# Setup node version manager
# export NVM_DIR="/home/vadim/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Enable fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh



# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!

CONDA_ROOT="$HOME/opt/conda_arm/"

__conda_setup=$("$CONDA_ROOT/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/$CONDA_ROOT/etc/profile.d/conda.sh" ]; then
        . "/$CONDA_ROOT/etc/profile.d/conda.sh"
    else
        export PATH="/$CONDA_ROOT/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
