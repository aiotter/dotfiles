#!/bin/bash

WIDTH=${1}

SMALL=80
MEDIUM=140

# battery にパスを通す
PATH=$HOME/local/bin:$PATH

# オンラインステータスの取得
ping 'google.com' -c 1 >/dev/null 2>&1
if [ $? == 0 ]
then
    online_status=" $(get-wifi-ssid)"
else
    online_status="#[bg=cyan,fg=black] *OFFLINE* #[default]"
fi

# 起動中の Docker イメージの数を表示
function prompt_docker() {
  local docker_ps_result
  if docker_ps_result=$(docker ps -q 2>/dev/null); then
    containers="$(echo -n "$docker_ps_result" | wc -l | tr -d ' ')"
    echo " ${containers/0/} UP"
  else
    echo ' DOWN'
  fi
}

function simple_prompt_docker() {
  if docker_ps_result=$(docker ps -q 2>/dev/null); then
    containers="$(echo -n "$docker_ps_result" | wc -l | tr -d ' ')"
    echo " ${containers}"
  else
    echo ' ×'
  fi
}

if [ "$WIDTH" -gt "$MEDIUM" ]
then
    # 画面幅が十分大きいとき
    echo " #[fg=cyan]${online_status} $(battery -t -g blue)  $(prompt_docker) $(date +'[%a %d-%m-%Y %H:%M]') "
elif [ "$WIDTH" -ge "$SMALL" ]
then
    # 画面幅が中くらいのとき
    echo " #[fg=cyan]$(battery -t -g blue)  $(simple_prompt_docker) $(date +'[%a %d-%m-%Y %H:%M]')"
else
    # 画面幅が十分小さいとき
    echo ""
fi

