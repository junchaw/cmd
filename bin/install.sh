#!/bin/bash

if [ -e ~/.bash_profile ]; then
    file=~/.bash_profile
else
    file=~/.bashrc
fi

echo $file

pwd=$(pwd)
alias="alias cmd='source ${pwd}/bin/cmd.sh'"

checkAlias=$(cat ${file} | grep  -E "(^${alias}$)")

if [ -z "${checkAlias}" ]; then
    echo "${alias}" >> ${file}
fi

chmod +x bin/cmd.sh
