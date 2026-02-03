#!/usr/bin/env python3
import logging
import os
import shlex
import shutil
import subprocess
import warnings
from copy import deepcopy
from pathlib import Path

import click
import yaml

LOGGING_FORMAT = "%(asctime)s %(name)s [%(levelname)s]: %(message)s"

try:
    import coloredlogs

    coloredlogs.install(level="INFO", fmt=LOGGING_FORMAT)
except ImportError:
    logging.basicConfig(level=logging.INFO, format=LOGGING_FORMAT)

logger = logging.getLogger("dotfiles")


config = None
prev_config = None
verbose = 0

DEFAULT_CONFIG = "dotfiles.yaml"
DEFAULT_COPY_MODE = "hard"


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
    default=DEFAULT_COPY_MODE,
)
@main.command("add")
def add(files, group, to, copy_mode):
    """Copy new file and update config"""
    config_group = get_config_group(group)
    assert config_group is not None

    dest_dir = Path.cwd()
    if to is not None:
        dest_dir = dest_dir / to
    dest_dir.mkdir(exist_ok=True, parents=True)

    for file in files:
        file_path = Path(file)
        assert file_path.exists()
        local_path = copy_tree(file_path, dest_dir, mode=copy_mode, only_newer=True)
        if local_path is not None:
            local_path = local_path.relative_to(Path.cwd()).as_posix()
            detect_submodules(Path(local_path).resolve())
            config_group[local_path] = serialize_path(file_path)


@main.command("sync")
@click.option("-g", "--group", type=str)
@click.option(
    "-m",
    "--copy-mode",
    type=click.Choice(("hard", "soft", "copy", "none")),
    default=DEFAULT_COPY_MODE,
)
@click.option("--submodules", is_flag=True, help="Also sync git submodules by revision")
def sync(group, copy_mode, submodules):
    config_group = get_config_group(group)

    def _sync_group(group):
        for local, deploy in group.items():
            if isinstance(deploy, dict):
                _sync_group(deploy)
            else:
                local_path = Path(local)
                deploy_path = Path(deploy).expanduser().resolve()

                # Determine sync direction based on timestamps
                if local_path.exists() and deploy_path.exists():
                    local_time = local_path.stat().st_ctime
                    deploy_time = deploy_path.stat().st_ctime

                    if local_time > deploy_time:
                        # Local is newer - deploy it instead
                        if verbose:
                            logger.info(f"Local {local_path} is newer, deploying to {deploy_path}")
                        copy_tree(
                            local_path,
                            deploy_path.parent,
                            deploy_path.name,
                            mode=copy_mode,
                            only_newer=False,
                        )
                        continue

                # Default: copy from deployed to local
                copy_tree(
                    deploy_path,
                    local_path.parent,
                    local_path.name,
                    mode=copy_mode,
                )
                detect_submodules(local_path)

    _sync_group(config_group)

    if submodules:
        _sync_submodules(config_group)


def _sync_submodules(group):
    """Sync git submodules between repo and deployed locations."""
    for local, deploy in group.items():
        if isinstance(deploy, dict):
            _sync_submodules(deploy)
        else:
            local_path = Path(local)
            deploy_path = Path(deploy).expanduser().resolve()

            # Find git repos in local path
            for repo in find_git_repos(local_path):
                relative = repo.relative_to(local_path)
                deployed_repo = deploy_path / relative
                if deployed_repo.exists():
                    sync_submodule(repo, deployed_repo)


@main.command("status", help="Check whether deployed files are up-to-date")
@click.option("-g", "--group", type=str)
@click.option(
    "-m",
    "--copy-mode",
    type=click.Choice(("hard", "soft", "copy", "none")),
    default=DEFAULT_COPY_MODE,
)
@click.option("--submodules", is_flag=True, help="Also check git submodule revisions")
def status(group, copy_mode, submodules):
    config_group = get_config_group(group)
    ok = True

    def _status_group(group):
        nonlocal ok
        for local, deploy in group.items():
            if isinstance(deploy, dict):
                _status_group(deploy)
            else:
                local_path = Path(local)
                deploy_path = Path(deploy).expanduser().resolve()
                ok &= status_tree(
                    local_path, deploy_path.parent, deploy_path, copy_mode
                )

    _status_group(config_group)

    if submodules:
        ok &= _status_submodules(config_group)

    if ok:
        logger.info("All files are identical")
    else:
        logger.warning("Some changes detected")


def _status_submodules(group) -> bool:
    """Check if git submodules are in sync between repo and deployed locations."""
    ok = True
    for local, deploy in group.items():
        if isinstance(deploy, dict):
            ok &= _status_submodules(deploy)
        else:
            local_path = Path(local)
            deploy_path = Path(deploy).expanduser().resolve()

            for repo in find_git_repos(local_path):
                relative = repo.relative_to(local_path)
                deployed_repo = deploy_path / relative
                if not deployed_repo.exists():
                    continue

                repo_rev = get_git_revision(repo)
                deploy_rev = get_git_revision(deployed_repo)

                if repo_rev is None or deploy_rev is None:
                    logger.warning(f"Submodule {repo.name}: could not get revision")
                    ok = False
                elif repo_rev != deploy_rev:
                    logger.warning(
                        f"Submodule {repo.name}: repo={repo_rev[:8]} deployed={deploy_rev[:8]}"
                    )
                    ok = False
    return ok


@main.command("deploy")
@click.option("-g", "--group", type=str)
@click.option(
    "-m",
    "--copy-mode",
    type=click.Choice(("hard", "soft", "copy", "none")),
    default="none",
)
@click.option("-f", "--force", is_flag=True)
@click.option("--submodules", is_flag=True, help="Also deploy git submodule revisions")
def deploy(group, copy_mode, force, submodules):
    config_group = get_config_group(group)

    if copy_mode == "none":
        warnings.warn(
            "You must set copy mode explicitly (--copy-mode hard), by default only displaying output"
        )

    if force:
        only_newer = False  # Force overwrite regardless of timestamps
    else:
        only_newer = True   # Only copy if source is newer

    def _deploy_group(group):
        for local, deploy in group.items():
            if isinstance(deploy, dict):
                _deploy_group(deploy)
            else:
                deploy_path = Path(deploy).expanduser().absolute()
                copy_tree(
                    Path(local),
                    deploy_path.parent,
                    deploy_path.name,
                    mode=copy_mode,
                    only_newer=only_newer,
                )

    _deploy_group(config_group)

    if submodules:
        _deploy_submodules(config_group)


def _deploy_submodules(group):
    """Deploy git submodule revisions to deployed locations."""
    for local, deploy in group.items():
        if isinstance(deploy, dict):
            _deploy_submodules(deploy)
        else:
            local_path = Path(local)
            deploy_path = Path(deploy).expanduser().resolve()

            for repo in find_git_repos(local_path):
                relative = repo.relative_to(local_path)
                deployed_repo = deploy_path / relative
                if deployed_repo.exists():
                    repo_rev = get_git_revision(repo)
                    if repo_rev:
                        if not is_worktree_clean(deployed_repo):
                            logger.warning(f"Deployed {deployed_repo} has changes, skipping")
                            continue
                        deploy_rev = get_git_revision(deployed_repo)
                        if deploy_rev != repo_rev:
                            logger.info(f"Deploying {deployed_repo} to {repo_rev[:8]}")
                            checkout_revision(deployed_repo, repo_rev)


@main.result_callback()
def finalize(*args, **kwargs):
    config_path = kwargs["config_path"]

    if verbose > 0:
        logger.info("Current config: ")
        logger.info(config)

    if prev_config != config:
        with open(config_path, "w") as f:
            yaml.dump(config, f)
            # json.dump(config, f, sort_keys=True, indent=4)


def status_tree(local_path: Path, deploy_dir, deploy_file: Path, mode="hard"):
    # Skip .git directories - they contain instance-specific git state
    if local_path.name == ".git":
        return True

    status = True
    if not deploy_file.exists():
        logger.warning(f"File {local_path} does not exists at {deploy_dir}")
        return False

    if local_path.is_dir():
        if not deploy_file.is_dir():
            logger.warning(f"Deployed file {deploy_file} is not a directory.")
            return False

        local_files = list(local_path.iterdir())
        deployed_files = list(deploy_file.iterdir())

        local_names = set([p.name for p in local_files])
        deploy_names = set([p.name for p in deployed_files])
        if local_names != deploy_names:
            logger.warning(
                f"Directories {local_path} and {deploy_file} are not the same!"
            )
            l_diff = local_names.difference(deploy_names)
            r_diff = deploy_names.difference(local_names)
            if len(l_diff) > 0:
                diff_names = ", ".join(list(l_diff)[:5])
                if len(l_diff) > 5:
                    diff_names = diff_names + "..."
                logger.warning(
                    f"Directory {deploy_file} missing {len(l_diff)} more files: {diff_names}"
                )
            if len(r_diff) > 0:
                diff_names = ", ".join(list(r_diff)[:5])
                if len(r_diff) > 5:
                    diff_names = diff_names + "..."
                logger.warning(
                    f"Directory {deploy_file} have {len(r_diff)} not added files: {diff_names}"
                )
            status = False

        # Step into subdirectories
        for name in local_names & deploy_names:
            status &= status_tree(local_path / name, deploy_file, deploy_file / name)
        return status

    # Both files are plain files or symlinks
    if deploy_file.is_dir():
        logger.warning(
            f"File {local_path} is plain file but {deploy_file} is a directory "
        )
        return False
    # both local and deployed are plain files
    if local_path.samefile(deploy_file):
        # identical files
        logger.debug(f"Same files {local_path} {deploy_file}")
        return True

    if mode in ("hard", "copy") and deploy_file.is_symlink():
        logger.warning(f"File {deploy_file} is a symlink, but mode={mode}")
        return False
    elif mode == "soft" and not deploy_file.is_symlink():
        logger.warning(f"File {deploy_file} is not symlink.")
        return False

    if mode == "hard":
        logger.warning(f"Files {local_path} and {deploy_file} are not the same.")
    elif mode == "copy" and not files_are_same(local_path, deploy_file):
        logger.warning(f"Files {local_path} and {deploy_file} differ")
    elif mode == "soft" and deploy_file.readlink().resolve() != local_path.resolve():
        logger.warning(
            f"Link {deploy_file} points to a different file ({deploy_file.readlink()})"
        )
    else:
        return True
    return False


def copy_tree(
    file_or_dir: Path, destination_dir: Path, destination_file: Path = None, **copy_args
):
    if destination_file is None:
        destination_file = file_or_dir.name

    # Skip .git directories - they contain instance-specific git state
    if destination_file == ".git":
        return None

    destination_dir.mkdir(exist_ok=True, parents=True)
    destination_path = destination_dir / destination_file

    if file_or_dir.is_file():
        copy_file(file_or_dir, destination_path, **copy_args)
    elif file_or_dir.is_dir():
        for file in file_or_dir.iterdir():
            copy_tree(file, destination_path, **copy_args)
    else:
        raise FileNotFoundError(f"path: {file_or_dir}")
    return destination_path


def copy_file(src: Path, dst: Path, mode="hard", only_newer=True):
    assert mode in ("hard", "soft", "copy", "none")
    if dst.is_symlink() and mode == "soft":
        # We need to handle symlinks before checking for file existence
        # dst.exists() will return existance of the symlink target
        # rather than the symlink itself

        # We need to remove old symlink before creating a new one
        # otherwise os.symlink will fail
        logger.info(f"Removing old symlink {dst}")
        # Since mode == "soft", we are not in dry-run and must remove the symlink
        dst.unlink()
    elif dst.exists() and only_newer:
        # Do replace destination file if it is newer than source
        src_time = src.stat().st_ctime
        dst_time = dst.stat().st_ctime
        if dst_time >= src_time:
            if verbose:
                logger.info(f"Skipping {dst} -> {src} (not older)")
            return

        if dst.is_dir():
            logger.error(
                f"File {dir} is a directory, but {src} is a plain file. Can not replace it"
            )
            raise IsADirectoryError(f"Can not replace {dst} with {src}")
    elif dst.is_symlink():
        # Can be tricky to handle symlinks
        logger.error(f"File {dst} is a symlink, but mode={mode}")
        return

    if verbose:
        logger.info(f"Copying {src} -> {dst} mode={mode}")

    # Remove destination file if it exists
    # At this point we know that target is not newer than src
    if dst.is_file() or dst.is_symlink():
        logger.info(f"File {dst} already exists, but {src} is newer! Replacing it")
        # Do not remove files in dry-run mode!
        if mode != "none":
            dst.unlink()

    if mode == "hard":
        os.link(src, dst)
    elif mode == "soft":
        logger.info(f"Creating symlink {src.absolute()} -> {dst}")
        os.symlink(src.absolute(), dst)
    elif mode == "copy":
        shutil.copy2(src, dst)


def get_config_group(group):
    config_file_list: dict = config.setdefault("files", {})
    if group is not None:
        config_group = config_file_list.setdefault(group, {})
    else:
        config_group = config_file_list
    if config_group is None:
        # Empty dict keys in PyYAML are None by default
        return {}
    return config_group


def serialize_path(path: Path):
    home_str = Path.home().as_posix()
    path_str = path.resolve().as_posix()

    if path_str.startswith(home_str):
        return "~" + path_str[len(home_str) :]
    return path_str


def run_command(cmd):
    cmd = shlex.split(cmd)
    with subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as proc:
        output, err = proc.communicate()
        code = proc.wait()
    return code, output.decode(), err.decode() if err else ""


def get_git_revision(path: Path) -> str | None:
    """Get HEAD commit hash of a git repo."""
    code, out, _ = run_command(f"git -C {path} rev-parse HEAD")
    return out.strip() if code == 0 else None


def get_commit_timestamp(path: Path, commit: str = "HEAD") -> int | None:
    """Get unix timestamp of a commit."""
    code, out, _ = run_command(f"git -C {path} log -1 --format=%ct {commit}")
    return int(out.strip()) if code == 0 else None


def is_worktree_clean(path: Path) -> bool:
    """Check if git worktree has no uncommitted changes."""
    code, out, _ = run_command(f"git -C {path} status --porcelain")
    return code == 0 and out.strip() == ""


def checkout_revision(path: Path, revision: str) -> bool:
    """Checkout a specific revision in a git repo."""
    code, _, _ = run_command(f"git -C {path} checkout {revision}")
    return code == 0


def find_git_repos(path: Path) -> list[Path]:
    """Find all git repositories under a path (by .git directory).

    Excludes the path itself if it's a git repo.
    """
    repos = []
    if not path.exists():
        return repos
    for git_dir in path.rglob(".git"):
        if git_dir.is_dir():
            repo_path = git_dir.parent
            # Exclude the root path itself
            if repo_path != path:
                repos.append(repo_path)
    return repos


def sync_submodule(repo_path: Path, deploy_path: Path) -> bool:
    """Sync a submodule between repo and deployed location.

    Returns True if sync was successful or no action needed.
    """
    repo_rev = get_git_revision(repo_path)
    deploy_rev = get_git_revision(deploy_path)

    if repo_rev is None or deploy_rev is None:
        logger.warning(f"Could not get revision for {repo_path} or {deploy_path}")
        return False

    if repo_rev == deploy_rev:
        logger.debug(f"Submodule {repo_path} already in sync")
        return True

    repo_time = get_commit_timestamp(repo_path, repo_rev)
    deploy_time = get_commit_timestamp(deploy_path, deploy_rev)

    if repo_time is None or deploy_time is None:
        logger.warning(f"Could not get timestamps for {repo_path}")
        return False

    if deploy_time > repo_time:
        # Deployed is newer - update repo
        if not is_worktree_clean(repo_path):
            logger.warning(f"Repo submodule {repo_path} has uncommitted changes, skipping")
            return False
        logger.info(f"Updating repo submodule {repo_path} to {deploy_rev[:8]}")
        return checkout_revision(repo_path, deploy_rev)
    else:
        # Repo is newer - update deployed
        if not is_worktree_clean(deploy_path):
            logger.warning(f"Deployed submodule {deploy_path} has uncommitted changes, skipping")
            return False
        logger.info(f"Updating deployed submodule {deploy_path} to {repo_rev[:8]}")
        return checkout_revision(deploy_path, repo_rev)


def detect_submodules(path: Path):
    curdir = Path.cwd()
    for folder in path.rglob(".git"):
        folder = folder.parent
        os.chdir(folder.as_posix())
        code, url, _ = run_command("git remote get-url origin")
        if code:
            continue
        logger.info(f"Detected submodule at {folder}")
        os.chdir(curdir.as_posix())
        relative_folder = folder.resolve().relative_to(curdir)
        run_command(f"git submodule add {url} {relative_folder}")
    os.chdir(curdir.as_posix())


def files_are_same(src: Path, dst: Path):
    if src.stat().st_size != dst.stat().st_size:
        return False
    code1, out1, _ = run_command(f"md5sum {src}")
    code2, out2, _ = run_command(f"md5sum {dst}")
    if code1 != 0 or code2 != 0:
        raise RuntimeError("md5sun returned non zero exit code.")
    if out1.split()[0] != out2.split()[0]:
        return False
    return True


if __name__ == "__main__":
    main()
