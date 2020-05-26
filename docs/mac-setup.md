MAC でのセットアップ
=====

- システム設定
    - 余計なキーバインドを解除
        - システム環境設定 -> キーボード -> ショートカット -> Mission Control
            - Ctrl+↑: Mission Control を無効にする
            - Ctrl+↓: アプリケーションウィンドウ を無効にする
            - Ctrl+[←→]: Mission Control -> [左右]の操作スペースに移動 を無効にする
        - システム環境設定 -> キーボード -> ショートカット -> 入力ソース
            - Ctrl+Space: 前の入力ソースを選択 を無効にする
            - Shift+Ctrl+Space: 入力メニューの次の入力ソースを選択 を無効にする

- neovim
    - カラースキーマが読み込まれなくなったときにやること
        - `:call dein#recache_runtimepath()` を実行して runtimepath を更新する


- [iTerm2](https://www.iterm2.com/)
    - Preferences -> Profiles
        - Colors -> Color Presets -> Pastel (Dark background)
        - General -> Applications in terminal may access clipboard
        - Keys -> Key Mappings
            - Tab キーとその他の装飾キーを組み合わせた入力への対応
              ([参考](https://tmsanrinsha.net/post/2012/07/ターミナルでctrltabとかを使う/))
                1. Shift + Tab
                    - Action: Send Escape Sequence
                    - Esc+ [27;2;9~
                2. Ctrl + Tab
                    - Action: Send Escape Sequence
                    - Esc+ [27;5;9~
                3. Ctrl + Shift + Tab
                    - Action: Send Escape Sequence
                    - Esc+ [27;6;9~

