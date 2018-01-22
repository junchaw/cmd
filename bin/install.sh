#!/bin/bash

if [ -e ~/.bash_profile ]; then
    file=~/.bash_profile
else
    file=~/.bashrc
fi

pwd=$(pwd)
alias="alias cmd='source ${pwd}/bin/cmd.sh'"

checkAlias=$(cat ${file} | grep  -E "(^${alias}$)")

if [ -z "${checkAlias}" ]; then
    echo "${alias}" >> ${file}
fi

echo -e "请指定本地命令文件的路径:\n(如 ${pwd}/personal/example.commands):"
read -p "" path
echo ${path} > "${pwd}/commands_file"

chmod +x bin/cmd.sh

echo -e "\n安装完毕, 重启终端后可以使用 cmd 命令"
