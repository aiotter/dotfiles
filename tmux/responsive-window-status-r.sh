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


if [ "$WIDTH" -gt "$MEDIUM" ]
then
    # 画面幅が十分大きいとき
    echo " #[fg=cyan]${online_status} $(battery -et -g blue) $(date +'[%a %d-%m-%Y %H:%M]')"
elif [ "$WIDTH" -ge "$SMALL" ]
then
    # 画面幅が中くらいのとき
    echo " #[fg=cyan]$(battery -et -g blue) $(date +'[%a %d-%m-%Y %H:%M]')"
else
    # 画面幅が十分小さいとき
    echo ""
fi

