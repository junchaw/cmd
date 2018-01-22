# cmd

> All commands in one

### Purpose

日常工作中经常需要输入一些很长的命令, 或者好几句需要连续执行的命令, 比如:

`ssh -p 59393 192.168.33.110`

或者

`sudo /etc/init.d/nginx restart && sudo /etc/init.d/php-fpm restart`

输的次数一多就会很烦琐, 尤其还输错了一两个字符的时候更让人抓狂.

在一串命令中输错一两个字符是非常让人沮丧的事情, 以至于 3 万多个沮丧的程序员纷纷给 [nvbn/thefuck](https://github.com/nvbn/thefuck) 这样的项目点了 Star.

#### 复制, 粘贴

遇到这种情况, 最简单的当然是 `CTRL + C` 与 `CTRL + V`, 不过显然这种方法过于弱鸡, 以至于我不想再说什么.

#### 历史命令

命令很少时候可以用方向键选择历史命令并重复执行, 但是命令一多, 要找到对的那一条就会很难.

#### 历史命令搜索

然后你可以会想到用 `CTRL + R` 搜索历史命令, 这当然很好, 不过, 毕竟是搜索的结果, 不一定能够顺利找到你要的那一条.

> [How To Use Bash History Commands and Expansions on a Linux VPS](https://www.digitalocean.com/community/tutorials/how-to-use-bash-history-commands-and-expansions-on-a-linux-vps)

#### 别名

对于一些极为频繁使用的命令, 通常可以设置别名解决这个问题, 比如 `alias ..='cd ..'`, 或者直接把它放到 `.bashrc` 文件里.

别名设置一多, 管理起来也会变得麻烦, 而且对每个新的别名, 要编辑 `.bashrc` 文件, 不可谓不麻烦.

### cmd!

用这个简单的小工具, 为一条命令设置一个编号只需要:

`cmd add 11 'ssh -p 59393 192.168.33.110'`

然后就可以通过

`cmd 11`

执行配置好的命令了!

更关键的是, 配置好的命令可以以文件为单位上传到 git 仓库里, 再也没有到处配置同一条命令的烦恼了!

### Installation

如何安装:

克隆仓库: `git clone git@gitlab.dxy.net:wujc/cmd.git`

然后安装: `chmod +x ./install.sh && ./install.sh`

然后重启终端

然后 `cmd help`

>  [Linux 设置 PATH 环境变量的方法](https://wujunchao.com/blog/p/214)

### How-To

如何使用:

内置的命令只有 7 条:

- 列出命令: `cmd`
- 执行命令: `cmd ${index}`
- 添加命令: `cmd add ${index} ${command}`
- 删除命令: `cmd remove ${index}`
- 替换命令: `cmd replace ${index} ${command}`
- 查找命令: `cmd find ${index}`
- 帮助: `cmd help`

Examples:

- `cmd`
- `cmd 1`
- `cmd add 2 'ls -al'`
- `cmd remove 2`
- `cmd replace 2 'ls -al'`
- `cmd find 2`

> 请尽量不要将保留的几个关键字 'add', 'remove', 'replace', 'find', 'help' 注册为命令, 除非你知道你正在做什么.

Enjoy~
