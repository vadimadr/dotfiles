#!/usr/bin/python3
import subprocess
import sys

# Try to focus window by executable name


def shell(*args):
    output = subprocess.check_output(args)
    return output.decode().strip().split("\n")


def get_executable(pid):
    with open(f"/proc/{pid}/comm") as f:
        return f.read().strip()


def main():
    if len(sys.argv) != 2:
        return -1

    window_name = sys.argv[1]

    # get list of open windows
    open_windows = [w.split() for w in shell("wmctrl", "-lp")]
    # sort by pid
    open_windows = sorted(open_windows, key=lambda w: int(w[2]))

    for win in open_windows:
        vpid = win[0]
        pid = win[2]
        executable = get_executable(pid)

        if executable == window_name:
            shell("wmctrl", "-ia", vpid)
            return

    return 1


if __name__ == "__main__":
    sys.exit(main())
