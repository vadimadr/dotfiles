pip_save() {
    package_name=$1
    requirements_file=$2
    if [[ -z $requirements_file ]]; then
        requirements_file='./requirements.txt'
    fi

    exec 5>&1
    intall_output=$(pip install ${package_name}|tee >(cat - >&5))
    freeze_output=`pip freeze`

    reqs=`python3 - << END

import os
import re

install_output_ = """$intall_output"""
freeze_output_ = """$freeze_output"""

m = re.search(r"collected packages: (.*)", install_output_)
if m:
    packs = m.group(1).strip().split(', ')
else:
    packs = []

reqs = []

for pack in packs:
    regex = r"^%s==.*$" % pack
    m = re.search(regex, freeze_output_, re.MULTILINE | re.IGNORECASE)

    if m: reqs.append(m.group(0))

print('\n'.join(reqs))

END`

    echo  "\nfollowing dependencies added to $requirements_file \n$reqs"

    echo $reqs >> $requirements_file

}