#!/bin/bash

# 各種tmux変数の取得
WIDTH=${1}
pane_current_command=$2
pane_pid=$3
pane_current_path=$4
cd "$pane_current_path"


# Git で index.lock を作成しないよう環境変数を設定
GIT_OPTIONAL_LOCKS=0


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
      echo $list | while read line; do
        host_user=${line#*|}
        if [[ "$host" =~ $line ]]; then
          user=$host_user
          break
        fi
      done
    fi
    # SSH接続時の表示
    echo "#[bg=red,fg=black][ ssh:$user@$host ]#[default]"
    exit 0
  fi
  # localhostでの実行時の表示
  echo "#[bg=colour236,dim][ localhost ]#[default]"
  exit 0
}


# venv仮想環境の検出処理
find-venv() {
  dir=$*
  while :
  do
    if [[ -e "${dir}/.venv" ]]
    then
      echo "$dir/.venv"
      break
    elif [[ "${dir}" = '/' ]] || [[ "${dir}" = '~' ]]
    then
      exit 0
    fi
    dir=$(dirname $dir)
  done
}

# venv仮想環境の情報の表示
echo-venv() {
  venv=$(find-venv "${pane_current_path}" | sed -E 's@^.+/([^/]*/\.venv)@\1@')
  if [[ -n $venv ]]
  then
    echo "VENV ON #[bold]$venv#[default]"
  else
    echo "#[dim]no venv#[default]"
  fi
}


# 渡された文字列がペインに入り切るときechoする
check-space() {
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
venv_result=$(echo-venv)

# 矢印の書式設定
cursor=" ⇱ "

# git管理下のとき
if git status >/dev/null 2>&1
then
  git_name=$(git config --get user.name)
  git_name=${git_name:-UNNAMED}
  git_email=$(git config --get user.email)
  git_email=${git_email:-not_set@invalid.email}
  git_style='#[reverse]'

  echo "${cursor}${host_result} | ${pane_current_command}(${pane_pid}) | ${git_style}Git: ${git_name}<${git_email}>#[default] | ${venv_result} " | check-space && exit 0
  echo "${cursor}${host_result} | ${pane_current_command}(${pane_pid}) | ${git_style}Git: ${git_name}<${git_email:0:5}...>#[default] | ${venv_result} " | check-space && exit 0
  echo "${cursor}${host_result} | ${pane_current_command}(${pane_pid}) | ${git_style}${git_name}<${git_email:0:5}...>#[default] " | check-space && exit 0
  echo "${cursor}${host_result} (${pane_pid}) | ${git_style}${git_name}#[default] " | check-space && exit 0
  echo "${cursor}${host_result} | ${git_style}${git_name}#[default] " | check-space && exit 0
  echo "${cursor}${host_result} [GIT] " | check-space && exit 0
fi


# 非Git管理下
echo "${cursor}${host_result} | ${pane_current_command}(${pane_pid}) | ${venv_result} " | check-space && exit 0
echo "${cursor}${host_result} | ${pane_current_command}(${pane_pid}) " | check-space && exit 0
echo "${cursor}${host_result} (${pane_pid}) " | check-space && exit 0
echo "${cursor}${host_result} " | check-space && exit 0
echo ""

