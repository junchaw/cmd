#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # 脚本目录
this="cmd"
commands_file="${DIR}/../commands_file"
temp="${DIR}/.temp"

arg1="$1"
arg2="$2"
arg3="$3"

clear

alias=$(alias)
if [ -z "${alias}" ]; then
    echo -e "\n请不要直接执行 ./cmd.sh, 请先执行 cmd 目录下的 ./install.sh 脚本, 然后重启你的终端"
    exit 1
fi
error () {
    echo -e "\n出错了:\n\n- 如果你正在尝试直接执行 ./cmd.sh, 请不要这么做\n"
    echo -e "- 如果你执行的是 cmd 命令, 那么很可能环境设置不正确, 请先执行 cmd 目录\n  下的 ./install.sh 脚本, 然后重启你的终端"
}

if [ ! -e ${commands_file} ]; then
    error
    return 0
fi

check_alias=$(alias | grep -E "(^alias cmd='source ${DIR}/cmd.sh'$)")
if [ -z "${check_alias}" ]; then
    error
    return 0
fi

commands=$(cat ${commands_file})

if [ ! -e ${commands} ]; then
    echo "cc cd ${DIR}" > ${commands}
fi

# 帮助
command_help () {
  echo "说    明: 本程序用于管理日常命令. 通过简单的操作, 将常用的命令统一在一个地方"
  echo "          进行管理, 功能与 alias 相同, 不过比 alias 更为强大."
  echo "仓库地址: git@gitlab.dxy.net:wujc/cmd.git"
  echo -e "技术支持: me@wujunchao.com\n"
  echo "可以使用的指令:"
  echo "  列出命令: ${this}" #
  echo "  执行命令: ${this} \${no}" #
  echo "  添加命令: ${this} add \${no} \${command}"
  echo "  删除命令: ${this} remove \${no}"
  echo "  替换命令: ${this} replace \${no} \${command}"
  echo "  查找命令: ${this} find \${no}"
  echo -e "  帮    助: ${this} help\n"
  echo "Examples:"
  echo "  ${this}"
  echo "  ${this} 1"
  echo "  ${this} add 2 'ls -al'"
  echo "  ${this} remove 2"
  echo "  ${this} replace 2 'ls -al'"
  echo "  ${this} find 2"
}

# 一句提示
help_notice () {
  echo -e "For help, run '${this} help'\n"
}

# 检查参数二是否传入
check_arg2 () {
  if [ -z "${arg2}" ]; then
    command_help
    return 1
  fi
}

# 检查参数三是否传入
check_arg3 () {
  if [ -z "${arg3}" ]; then
    command_help
    return 1
  fi
}

# 添加命令
add_command () {
  if ! check_arg2; then
      return
  fi

  if ! check_arg3; then
      return
  fi

  command=$(grep "^${arg2} .*$" ${commands})
  if [ -z "${command}" ]; then
    echo -e "Command added:\n\n${arg2} ${arg3}"
    echo ${arg2} ${arg3} >> ${commands}
  else
    echo -e "Command already exists:\n\n${command}"
  fi
}

# 删除命令
remove_command () {
  if ! check_arg2; then
      return
  fi

  command=$(grep "^${arg2} .*$" ${commands})
  if [ -z "${command}" ]; then
    echo -e "Command not found: ${arg2}\n"
    help_notice
  else
    echo -e "Command removed:\n\n${command}"
    # sed -iE "/^${arg2} .*/d" ${temp} ${commands} # -i in place, -E expression , sed 直接作用在软链接上有些问题, 待改进
    temp="${DIR}/commands-temp"
    cp ${commands} ${temp}
    sed -E "/^${arg2} .*/d" ${temp} > ${commands} # TODO: 命令编号带 ".", 删除时产生 bug
    rm ${temp}
  fi
}

# 替换命令
replace_command () {
  if ! check_arg3; then
      return
  fi

  remove_command
  echo -e "\n"
  add_command
}

# 查找命令
find_command () {
  if ! check_arg2; then
      return
  fi

  # @see list_commands
  while IFS= read -r line || [[ -n "${line}" ]]; do
    if [[ -z "${line}" ]]; then
      continue # 跳过空行
    fi;

    k=$(echo "${line}" | grep -Eo '(^[^ ]+)')
    v=${line#* }

    if [[ ${k} = ${arg2} ]]; then
      echo -e "Command found:\n\n${k}: ${v}"
      return
    fi
  done < "${commands}"

  echo -e "Command not found: ${arg2}\n"
  help_notice
}

# 列出命令
list_commands () {
  echo "Available commands:"

  # "IFS=" 阻止 trim 内容
  # -r 阻止转义反斜杠
  # -n "$line" 阻止最后一行被忽略 (如果文件最后没有空行)
  while IFS= read -r line || [[ -n "${line}" ]]; do
    if [[ -z "${line}" ]]; then
        continue # 跳过空行
    fi;
    k=$(echo "${line}" | grep -Eo '(^[^ ]+)')
    v=${line#* }

    printf -v space '%*s' $((8 - ${#k}))
    echo "${k}${space}${v}"

  done < "${commands}"
}

# 执行命令
# $1 no 指定命令
execute_command () {
  if [ -z "$1" ]; then
    no="${arg1}"
  else
    no="$1"
  fi

  # @see list_commands
  while IFS= read -r line || [[ -n "${line}" ]]; do
    if [[ -z "${line}" ]]; then
      continue # 跳过空行
    fi;

    _no=$(echo "${line}" | grep -Eo '(^[^ ]+)')
    command=${line#* }
    if [[ ${_no} = ${no} ]]; then
      echo -e "Executing command:\n\n${line}\n"
      #eval ${command} # 不可以在 function 中直接 ssh, 有待改进
      command_to_be_executed=${command}
      return 0
    fi
  done < "${commands}"

  echo -e "Command not found: ${no}\n"
  help_notice
}

command_to_be_executed=''

case "$arg1" in
  "add")
    add_command
    ;;
  "find")
    find_command
    ;;
  "help")
    command_help
    ;;
  "list")
    list_commands
    ;;
  "remove")
    remove_command
    ;;
  "replace")
    replace_command
    ;;
  "")
    list_commands
    read -p "请选择命令:" no
    if [ ! -z "${no}" ]; then
      execute_command ${no}
    else
      echo -e "\n\n已取消 (run 'cmd help' for help)\n"
    fi
    ;;
  *)
    execute_command
    ;;
esac

if [ ! -z "${command_to_be_executed}" ]; then
  echo -e "#!/bin/bash\n${command_to_be_executed}"  > ${temp}
  source ${temp} # 这样才可以在父 shell 切换目录
  rm ${temp}
fi

sort -n ${commands} -o ${commands} # -n 语义化数字 (2 排在 10 前面)
