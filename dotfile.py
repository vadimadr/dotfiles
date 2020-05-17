#!/usr/bin/env python3
import os
import shutil
from copy import deepcopy
from pathlib import Path
from pprint import pprint
import warnings
import subprocess
import shlex

import click
import yaml

config = None
prev_config = None
verbose = 0

DEFAULT_CONFIG = "dotfiles.yaml"
DEFAULY_COPY_MODE = "hard"


@click.group()
@click.option(
    "-c",
    "--config",
    "config_path",
    type=click.Path(dir_okay=False),
    default=DEFAULT_CONFIG,
)
@click.option("-v", "--verbose", "verbose_", count=True)
def main(config_path, verbose_):
    global config
    global prev_config
    global verbose

    verbose = int(verbose_)
    config_path = Path(config_path)
    if config_path.exists():
        with config_path.open() as f:
            config = yaml.load(f, Loader=yaml.FullLoader)
    else:
        config = {}
    prev_config = deepcopy(config)


@click.argument("files", nargs=-1)
@click.option("-g", "--group", type=str)
@click.option("-t", "--to", type=str)
@click.option(
    "-m",
    "--copy-mode",
    type=click.Choice(("hard", "soft", "copy", "none")),
    default=DEFAULY_COPY_MODE,
)
@main.command("add")
def add(files, group, to, copy_mode):
    """Copy new file and update config"""
    config_group = get_config_group(group)

    dest_dir = Path.cwd()
    if to is not None:
        dest_dir = dest_dir / to
    dest_dir.mkdir(exist_ok=True, parents=True)

    for file in files:
        file_path = Path(file)
        assert file_path.exists()
        local_path = copy_tree(file_path, dest_dir, mode=copy_mode, only_newer=True)
        local_path = local_path.relative_to(Path.cwd()).as_posix()
        detect_submodules(Path(local_path).resolve())
        config_group[local_path] = serialize_path(file_path)


@main.command("sync")
@click.option("-g", "--group", type=str)
@click.option(
    "-m",
    "--copy-mode",
    type=click.Choice(("hard", "soft", "copy", "none")),
    default=DEFAULY_COPY_MODE,
)
def sync(group, copy_mode):
    config_group = get_config_group(group)

    def _sync_group(group):
        for local, deploy in group.items():
            if isinstance(deploy, dict):
                _sync_group(deploy)
            else:
                copy_tree(
                    Path(deploy).expanduser().resolve(),
                    Path(local).parent,
                    Path(local).name,
                    mode=copy_mode,
                )

    _sync_group(config_group)


@main.command("deploy")
@click.option("-g", "--group", type=str)
@click.option(
    "-m",
    "--copy-mode",
    type=click.Choice(("hard", "soft", "copy", "none")),
    default="none",
)
@click.option("-f", "--force", is_flag=True)
def deploy(group, copy_mode, force):
    config_group = get_config_group(group)

    if copy_mode == "none":
        warnings.warn(
            "You must set copy mode explicitly (--copy-mode hard), by default only displaying output"
        )

    if force:
        only_newer = False
    else:
        only_newer = False

    def _deploy_group(group):
        for local, deploy in group.items():
            if isinstance(deploy, dict):
                _deploy_group(deploy)
            else:
                deploy_path = Path(deploy).expanduser().resolve()
                copy_tree(
                    Path(local),
                    deploy_path.parent,
                    deploy_path.name,
                    mode=copy_mode,
                    only_newer=only_newer,
                )

    _deploy_group(config_group)


@main.resultcallback()
def finalize(*args, **kwargs):
    config_path = kwargs["config_path"]

    if verbose > 0:
        print("Current config: ")
        pprint(config)

    if prev_config != config:
        with open(config_path, "w") as f:
            yaml.dump(config, f)
            # json.dump(config, f, sort_keys=True, indent=4)


def copy_tree(
    file_or_dir: Path, destination_dir: Path, destination_file: Path = None, **copy_args
):
    if destination_file is None:
        destination_file = file_or_dir.name
    destination_dir.mkdir(exist_ok=True, parents=True)
    destination_path = destination_dir / destination_file

    if file_or_dir.is_file():
        copy_file(file_or_dir, destination_path, **copy_args)
    elif file_or_dir.is_dir():
        for file in file_or_dir.iterdir():
            copy_tree(file, destination_path, **copy_args)
    else:
        raise FileNotFoundError
    return destination_path


def copy_file(src: Path, dst: Path, mode="hard", only_newer=True):
    assert mode in ("hard", "soft", "copy", "none")
    if dst.exists() and only_newer:
        src_time = src.stat().st_ctime
        dst_time = dst.stat().st_ctime
        if dst_time >= src_time:
            if verbose:
                print(f"Skipping {dst} -> {src} (not older)")
            return

    if verbose:
        print(f"Copying {src} -> {dst} mode={mode}")

    if mode == "hard":
        if os.path.exists(str(dst)):
            os.remove(str(dst))
        os.link(str(src), str(dst))
    elif mode == "soft":
        os.symlink(str(src), str(dst))
    elif mode == "copy":
        shutil.copy2(str(src), str(dst))


def get_config_group(group):
    config_file_list: dict = config.setdefault("files", {})
    if group is not None:
        config_group = config_file_list.setdefault(group, {})
    else:
        config_group = config_file_list
    return config_group


def serialize_path(path: Path):
    home_str = Path.home().as_posix()
    path_str = path.resolve().as_posix()

    if path_str.startswith(home_str):
        return "~" + path_str[len(home_str) :]
    return path_str


def run_command(cmd):
    cmd = shlex.split(cmd)
    with subprocess.Popen(cmd, stdout=subprocess.PIPE) as proc:
        output, err = proc.communicate()
        code = proc.wait()
    return code, output.decode(), err


def detect_submodules(path: Path):
    curdir = Path.cwd()
    for folder in path.rglob(".git"):
        folder = folder.parent
        os.chdir(folder.as_posix())
        code, url, _ = run_command("git remote get-url origin")
        if code:
            continue
        print(f"Detected submodule at {folder}")
        os.chdir(curdir.as_posix())
        relative_folder = folder.relative_to(curdir)
        run_command(f"git submodule add {url} {relative_folder}")
    os.chdir(curdir.as_posix())


if __name__ == "__main__":
    main()
