vadimadr dotfiles
======
My configuration files (.dotfiles), including:
- zsh
- vscode
- vim
- tmux
- ...

Using dotfiles.py
------
I created this simple script to simplify synchronization of deployed configurations with git repo.
It copies (creates hard links) files to the directory and stages them to config file (dotfiles.yaml) by default.
You can look at *dotfiles.yaml* to see what configs shared in this repo and how to deploy them.

Usage examples:

**Add (track new file):**
```
./dotfiles.py add ~/.some-app/config --group some-app --to some-app-configs
``` 

**Synchronize configs (copy updated files to root dir)**
```
./dotfiles.py sync 
```

**Deploy configurations**
```
./dotfiles.py deploy --group some-app --copy-mode copy
```
