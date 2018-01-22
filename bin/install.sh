#!/bin/bash

#file=test/.bash_profile
file=~/.bash_profile

checkAlias=$(cat ${file} | grep  -E "(^alias cmd=['\"]source cmd['\"]$)")

if [ -z "${checkAlias}" ]; then
    echo 'alias cmd="source cmd"' >> ${file}
fi

chmod +x cmd
