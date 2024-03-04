# Setup virtualenv wrapper
if [[ -f $HOME/.local/bin/virtualenvwrapper.sh ]]; then
    WORKON_HOME=$HOME/.virtualenvs
    VIRTUALENVWRAPPER_SCRIPT=$HOME/.local/bin/virtualenvwrapper.sh
    VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    VIRTUALENVWRAPPER_VIRTUALENV=$HOME/.local/bin/virtualenv
    source  $HOME/.local/bin/virtualenvwrapper_lazy.sh

    # Init default virtual env
    # Do not execute python scripts at zsh init! Init env manually
    # Shell prompt will be corupeted otherwise

    DEFAULT_VIRTUAL_ENV=py36
    VIRTUALENVWRAPPER_PROJECT_FILENAME=.project
    VIRTUALENVWRAPPER_WORKON_CD=1
    VIRTUALENVWRAPPER_HOOK_DIR=$HOME/.virtualenvs

    # update: do not set VIRTUALENV by default to avoid conflicts with Conda
    # activate only when needed
    # PATH="$WORKON_HOME/$DEFAULT_VIRTUAL_ENV/bin:$PATH"
    # VIRTUAL_ENV=$HOME/.virtualenvs/py36
fi


# Setup CUDA
CUDA_HOME=/usr/local/cuda
[[ -d  $CUDA_HOME ]] && LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${CUDA_HOME}/lib64"

# Setup node version manager
NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"  # This loads nvm

# Enable fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# Python PyENV
if [[ -d  "$HOME/.pyenv/bin" ]]; then 
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# [ -f $(which pyenv) ] && eval "$(pyenv init --path)"


# workaround to make conda appear first in PATH list 
unset CONDA_SHLVL

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!

_conda_search_paths=(
    "$HOME/opt/conda_arm"
    "$HOME/anaconda3"
    "$HOME/conda"
)

for _conda_path in ${_conda_search_paths[@]}; do
    if [ -d ${_conda_path} ]; then
        CONDA_ROOT=$_conda_path
        break
    fi
done

__conda_setup=$("$CONDA_ROOT/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$CONDA_ROOT/etc/profile.d/conda.sh" ]; then
        . "$CONDA_ROOT/etc/profile.d/conda.sh"
    else
        export PATH="$CONDA_ROOT/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Set default conda environment
if [[ -d $CONDA_ROOT/envs/dev ]]; then
    conda activate dev
fi