MAC でのセットアップ
=====

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

