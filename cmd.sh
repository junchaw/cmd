#!/bin/bash

this="cmd"
commands="./commands-available"

arg1="$1"
arg2="$2"
arg3="$3"

# 帮助
help () {
  echo "列出命令: ${this}" #
  echo "执行命令: ${this} \${index}" #
  echo "添加命令: ${this} add \${index} \${command}"
  echo "删除命令: ${this} remove \${index}"
  echo "替换命令: ${this} replace \${index} \${command}"
  echo "查找命令: ${this} find \${index}"
  echo "帮    助: ${this} help"
  echo ""
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

# 检查命令文件是否存在
check_commands_file_exists () {
  if [ ! -f ${commands} ]; then
    echo -e "File not exists: ${commands}\n"
    help_notice
    return 1
  fi
}

# 检查参数二是否传入
check_arg2 () {
  if [ -z $arg2 ]; then
    help
    return 1
  fi
}

# 检查参数三是否传入
check_arg3 () {
  if [ -z "${arg3}" ]; then
    help
    return 1
  fi
}

# 添加命令
add_command () {
  if ! check_commands_file_exists; then
    return
  fi

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
  if ! check_commands_file_exists; then
    return
  fi

  if ! check_arg2; then
      return
  fi

  command=$(grep "^${arg2} .*$" ${commands})
  if [ -z "${command}" ]; then
    echo -e "Command not found: ${arg2}\n"
    help_notice
  else
    echo -e "Command removed:\n\n${command}"
    sed -iE "/^${arg2} .*/d" ${commands} # -i in place, -E expression
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
  if ! check_commands_file_exists; then
    return
  fi

  if ! check_arg2; then
      return
  fi

  # @see list_commands
  while IFS= read -r line || [[ -n "${line}" ]]; do
    if [[ -z "${line}" ]]; then
      continue # 跳过空行
    fi;

    k=$(echo "${line}" | grep -Eo '(^\d+)')
    v=${line#* }

    if [[ ${k} = ${arg2} ]]; then
      echo -e "Command found ${k}: ${v}\n"
      return
    fi
  done < "${commands}"

  echo -e "Command not found: ${arg2}\n"
  help_notice
}

# 列出命令
list_commands () {
  if ! check_commands_file_exists; then
    return
  fi

  echo -e "Available commands:\n"

  # "IFS=" 阻止 trim 内容
  # -r 阻止转义反斜杠
  # -n "$line" 阻止最后一行被忽略 (如果文件最后没有空行)
  while IFS= read -r line || [[ -n "${line}" ]]; do
    if [[ -z "${line}" ]]; then
        continue # 跳过空行
    fi;
    k=$(echo "${line}" | grep -Eo '(^\d+)')
    v=${line#* }

    printf -v space '%*s' $((8 - ${#k}))
    echo "${k}${space}${v}"

  done < "${commands}"

  echo ""
  help_notice
}

# 操作某条命令
operate_command () {
  case "$arg1" in
    "add")
      add_command
    ;;
    "remove")
      remove_command
    ;;
    "replace")
      replace_command
    ;;
    "find")
      find_command
    ;;
    "")
      list_commands
    ;;
    *)
      help
    ;;
  esac
}

# 执行命令
execute_command () {
  if ! check_commands_file_exists; then
    return
  fi

  # @see list_commands
  while IFS= read -r line || [[ -n "${line}" ]]; do
    if [[ -z "${line}" ]]; then
      continue # 跳过空行
    fi;

    index=$(echo "${line}" | grep -Eo '(^\d+)')
    command=${line#* }
    if [[ ${index} = ${arg1} ]]; then
      echo -e "Executing command:\n\n${line}\n"
      #eval ${command} # 不可以在 function 中直接 ssh, 有待改进
      command_to_be_executed=${command}
      return
    fi
  done < "${commands}"

  echo -e "Command not found: ${arg1}\n"
  help_notice
}

clear

command_to_be_executed=''

reg='^[0-9]+$'
if [[ $arg1 =~ $reg ]] ; then
  execute_command # 如果是数字, 执行对应指令
  ${command_to_be_executed}
else
  operate_command # 如果非数字, 执行指令操作
fi

sort ${commands} -o ${commands}
