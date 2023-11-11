# need to source completions after antigen bundles (due to a bug: https://github.com/zsh-users/antigen/issues/736)

autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# this is still really weird...
# run echo -E $_comps[gcloud]
# to check that completion is loaded
# try running with ANTIGEN_CACHE=false
# see: https://github.com/zsh-users/antigen/issues/603#issuecomment-776286903 

# google cloud completions
gcloud_completions="/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
if [[ -f $gcloud_completions ]]; then
    source $gcloud_completions
fi

# if kubectl defined, load completions
if [[ -n $(command -v kubectl) ]]; then
    source <(kubectl completion zsh)
fi