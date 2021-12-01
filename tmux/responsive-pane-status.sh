#!/bin/bash

# 各種tmux変数の取得
WIDTH=${1}
pane_current_command=$2
pane_pid=$3
pane_current_path=$4
cd "$pane_current_path"


# Git で index.lock を作成しないよう環境変数を設定
export GIT_OPTIONAL_LOCKS=0


# hostname 取得処理
host() {
  if [[ ${pane_current_command} = "ssh" ]]; then
    info=$({ pgrep -flaP $pane_pid ; ps -o command -p $pane_pid; } | xargs -I{} echo {} | awk '/ssh/' | sed -E 's/^[0-9]*[[:blank:]]*ssh //')
    port=$(echo $info | grep -Eo '\-p ([0-9]+)'|sed 's/-p //')
    if [ -z $port ]; then
      local port=22
    fi
    info=$(echo $info | sed 's/\-p '"$port"'//g')
    user=$(echo $info | awk '{print $NF}' | cut -f1 -d@)
    host=$(echo $info | awk '{print $NF}' | cut -f2 -d@)

    if [ $user = $host ]; then
      user=$(whoami)
      list=$(awk '
        $1 == "Host" {
          gsub("\\\\.", "\\\\.", $2);
          gsub("\\\\*", ".*", $2);
          host = $2;
          next;
        }
        $1 == "User" {
        $1 = "";
          sub( /^[[:space:]]*/, "" );
          printf "%s|%s\n", host, $0;
        }' ~/.ssh/config
      )
      while read line; do
        host_user=${line#*|}
        if [[ "$host" =~ $line ]]; then
          user=$host_user
          break
        fi
      done < <(echo $list)
    fi
    # SSH接続時の表示
    echo "#[bg=red,fg=black][ $user@$host ]#[default]"
    exit 0
  fi
  # localhostでの実行時の表示
  echo "#[bg=colour236,dim][ $USER@localhost ]#[default]"
  exit 0
}

# 子孫プロセスを出力する
descendent_pids() {
  # print '[pid]|[command name]'
  data=$(lsof -a -d cwd -p $1 -Fcfp 2>/dev/null | sort | awk 'BEGIN {FS="\n"; RS=""; OFS="|"}; {print substr($3,2), substr($1,2)}')
  echo "$data"
  pids=$(pgrep -P $1)
  for pid in $pids; do
    descendent_pids $pid
  done
}

# 渡された文字列がペインに入り切るときechoする
print-if-capable() {
  local orig_msg=$(cat)
  local cleaned_msg=$(echo "$orig_msg" | sed -E 's/#\[[^]]+]//g')
  if [[ ${WIDTH} -gt ${#cleaned_msg}+4 ]]
  then
    echo "$orig_msg"
    exit 0
  else
    exit 1
  fi
}


# レスポンシブ対応
# 入り切る場合はechoしてexit、入り切らなければ情報量減らしてリトライ
host_result=$(host)

# 矢印の書式設定
cursor=" ⇱ "

current_command_pid="$(descendent_pids ${pane_pid} | awk -v cmd="${pane_current_command}" -F '|' '$2 == cmd { print $1 }' | tail -1)"
if git status >/dev/null 2>&1; then
  # git管理下のとき
  git_name=$(git config --get user.name)
  git_name=${git_name:-UNNAMED}
  git_email=$(git config --get user.email)
  git_email=${git_email:-not_set@invalid.email}
  git_style='#[reverse]'

  echo "${cursor}${host_result} | ${pane_current_command}(${current_command_pid}) | ${git_style} ${git_name}<${git_email}>#[default] " | print-if-capable && exit 0
  echo "${cursor}${host_result} | ${pane_current_command}(${current_command_pid}) | ${git_style} ${git_name}<${git_email:0:5}...>#[default] " | print-if-capable && exit 0
  echo "${cursor}${host_result} | ${pane_current_command}(${current_command_pid}) | ${git_style}${git_name}<${git_email:0:5}...>#[default] " | print-if-capable && exit 0
  echo "${cursor}${host_result} | ${pane_current_command}(${current_command_pid}) | ${git_style}${git_name}#[default] " | print-if-capable && exit 0
  echo "${cursor}${host_result} (${current_command_pid}) | ${git_style}${git_name}#[default] " | print-if-capable && exit 0
  echo "${cursor}${host_result} (${current_command_pid}) " | print-if-capable && exit 0
fi

# 非Git管理下
echo "${cursor}${host_result} | ${pane_current_command}(${current_command_pid}) " | print-if-capable && exit 0
echo "${cursor}${host_result} (${current_command_pid}) " | print-if-capable && exit 0
echo "${cursor}${host_result} " | print-if-capable && exit 0
echo ""
