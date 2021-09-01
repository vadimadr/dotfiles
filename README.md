vadimadr dotfiles
======
My configuration files (.dotfiles), including:
- zsh (antigen)
- vscode 
- vim (vim-plug)
- tmux
- ranger
- ...

Using dotfiles.py
------
I created this simple script to simplify synchronization of deployed configurations with git repo.
It copies (creates hard links) files to the directory and stages them to config file (dotfiles.yaml) by default.
You can look at *dotfiles.yaml* to see what configs shared in this repo and how to deploy them.

Usage examples:

**Deploy configurations**
```
./dotfiles.py deploy --group some-app --copy-mode hard
```

This will deploy (via hard linking at this time) all tracked files under *some-app* group to their primary destination.

**Add (track new file):**
```
./dotfiles.py add ~/.some-app/config --group some-app --to some-app-configs
``` 

Will add the following to the dotfiles.yaml:
```yaml
files:
  some-app:
    some-app-configs/config: ~/.some-app/config
```
And copy (by default creates hard link) `~/.some-app/config` to `some-app-configs/config`

**Synchronize configs (copy updated files to root dir)**
```
./dotfiles.py sync 
```

**Check whether files are updated**
```
./dotfiles.py status --group some-app
```

**Copy modes**

You can control how to track/deploy new files via `-m/--mode` flag:
- **hard**: Will create hard-links. Prefer this method if source root and file are in the same filesystem. 
- **soft**: Will create symlinks
- **copy**: Will use copy
- **none**: Use this mode (possibly with `--verbose` flag) to perform dry-runs (check what will happen)

Motivation for creating links instead of copying files is the following:
- Edit all dotfiles in single place (e.g. open dotfiles directory as workspace in VSCode)
- Automatically detect when will files change and track them in Git. 