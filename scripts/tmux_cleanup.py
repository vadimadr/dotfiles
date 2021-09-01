#!/usr/bin/env python3
import shlex
from subprocess import Popen, PIPE
import re

def command(cmd, silent=True) -> (int, str):
    if isinstance(cmd, str):
        cmd = shlex.split(cmd)
    process = Popen(cmd, stdout=PIPE)
    output, err = process.communicate()
    code = process.wait()
    return code, output.decode()


_, output = command('tmux ls')
num_killed = 0

for line in output.strip().split('\n'):
    m = re.match('(\d+): (\d+).*', line)
    is_attached = '(attached)' in line
    if m and not is_attached and m.group(2) == '1':
        session_name = m.group(1)
        command('tmux kill-session -t {}'.format(session_name))
        num_killed += 1

print('{} tmux sessions killed!'.format(num_killed))