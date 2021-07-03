#!/bin/bash

WIDTH=${1}

SMALL=80
MEDIUM=140

# battery にパスを通す
PATH=$HOME/local/bin:$PATH

# オンラインステータスの取得
ping 'google.com' -c 1 >/dev/null 2>&1
if [ $? == 0 ]; then
  interface="$(get-current-network-interface)"
  if echo $interface | grep -i wi-fi; then
    online_status=" $(get-wifi-ssid | sed -E 's/^(.{9}).*/\1…/')"
  else
    online_status=" WIRED"
  fi
else
  online_status="#[bg=cyan,fg=black] *OFFLINE* #[default]"
fi

# 起動中の Docker イメージの数を表示
function prompt_docker() {
  local docker_ps_result
  if docker_ps_result=$(docker ps -q 2>/dev/null); then
    containers="$(echo -n "$docker_ps_result" | wc -l | tr -d ' ')"
    echo " ${containers} UP"
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
    echo " #[fg=cyan]${online_status} $(battery -ptg blue)  $(prompt_docker) $(date +'[%a %d-%m-%Y %H:%M]') "
elif [ "$WIDTH" -ge "$SMALL" ]
then
    # 画面幅が中くらいのとき
    echo " #[fg=cyan]$(battery -ptg blue)  $(simple_prompt_docker) $(date +'[%a %d-%m-%Y %H:%M]')"
else
    # 画面幅が十分小さいとき
    echo ""
fi
