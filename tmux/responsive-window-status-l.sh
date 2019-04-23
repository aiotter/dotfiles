#!/bin/bash

WIDTH=${1}

SMALL=80
MEDIUM=140


if [ "$WIDTH" -gt "$MEDIUM" ]
then
    # 画面幅が十分大きいとき
    echo "on #[fg=green]#S/#[fg=yellow]#I/#[fg=cyan]#P"
elif [ "$WIDTH" -ge "$SMALL" ]
then
    # 画面幅が中くらいのとき
    echo ""
else
    # 画面幅が十分小さいとき
    echo ""
fi

