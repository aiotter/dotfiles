#!/bin/bash

WIDTH=${1}

SMALL=80
MEDIUM=140


# オンラインステータスの取得
ping 'google.com' -c 1 >/dev/null 2>&1
if [ $? == 0 ]
then
    online_status="-online-"
else
    online_status="#[bg=cyan,fg=black] *OFFLINE* #[default]"
fi

# 起動中の Docker イメージの数を取得
if type docker >/dev/null 2>&1; then
  containers="$(docker ps -q | wc -l | tr -d ' ')"
fi

if [ "$WIDTH" -gt "$MEDIUM" ]
then
    # 画面幅が十分大きいとき
    echo " #[fg=cyan]${online_status} $(battery -t -g blue) DOCK:$containers $(date +'[%a %d-%m-%Y %H:%M]')"
elif [ "$WIDTH" -ge "$SMALL" ]
then
    # 画面幅が中くらいのとき
    echo " #[fg=cyan]$(battery -t -g blue) $(date +'[%a %d-%m-%Y %H:%M]')"
else
    # 画面幅が十分小さいとき
    echo ""
fi

