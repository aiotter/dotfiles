# flake8: noqa F405
import datetime as dt
import os
import shutil
from functools import partial
from pathlib import Path
from subprocess import Popen, PIPE
from xkeysnail.transform import *


# [Global modemap] Change modifier keys as in xmodmap
# define_modmap({
#     Key.CAPSLOCK: Key.LEFT_CTRL
# })


# [Multipurpose modmap] Give a key two meanings. A normal key when pressed and
# released, and a modifier key when held down with another key. See Xcape,
# Carabiner and caps2esc for ideas and concept.
define_multipurpose_modmap({
    # Enter is enter when pressed and released. Control when held down.
    Key.ENTER: [Key.ENTER, Key.RIGHT_CTRL],

    # Capslock is escape when pressed and released. Control when held down.
    Key.CAPSLOCK: [Key.ESC, Key.LEFT_CTRL],
    # To use this example, you can't remap capslock with define_modmap.
})


# [Keymap]
# Super-key to exec command
def take_screenshot(area=False, to_clipboard=False):
    assert shutil.which('import') and shutil.which('xclip')
    commands = ['import']
    if not area:
        commands.extend(['-window', 'root'])
    if to_clipboard:
        commands.append('png:-')
        with Popen(commands, stdout=PIPE) as proc:
            Popen(['xclip', '-selection', 'clipboard', '-t', 'image/png'],
                  stdin=proc.stdout)
    else:
        XDG_PICTURES_DIR = os.environ.get('XDG_PICTURES_DIR', '~/Pictures')
        picture_path = Path(f'{XDG_PICTURES_DIR}/screenshots/'
                            f'{dt.datetime.now():%Y%m%d-%H%M%S}.png')
        picture_path = picture_path.expanduser()
        picture_path.parent.mkdir(parents=True, exist_ok=True)
        commands.append(picture_path)
        Popen(commands)

define_keymap(
    name='Super-key to exec',
    condition=None,
    mappings={
        K('Super-q'): launch(['bash', '-c', '''
            wid=$(xprop -root 32x '\t$0' _NET_ACTIVE_WINDOW | cut -f 2)
            pid=$(xprop -id $wid '\t$0' _NET_WM_PID | cut -f 2)
            kill -SIGHUP $pid
        ''']),
        K('Super-Shift-Key_3'):
            partial(take_screenshot, area=False, to_clipboard=False),
        K('Super-Shift-C-Key_3'):
            partial(take_screenshot, area=False, to_clipboard=True),
        K('Super-Shift-Key_4'):
            partial(take_screenshot, area=True, to_clipboard=False),
        K('Super-Shift-C-Key_4'):
            partial(take_screenshot, area=True, to_clipboard=True),
    }
)


# Keybindings for terminal apps
def is_terminal(wm_class):
    return wm_class in ['xfce4-terminal', 'gnome-terminal-server', 'Alacritty']
define_keymap(
    name='Clipboard on terminal',
    condition=is_terminal,
    mappings={
        K('Super-c'): K('C-Shift-c'),
        K('Super-v'): K('C-Shift-v')}
)


# Keybindings for Chromium
def is_chromium(wm_class):
    return wm_class in ['google-chrome', 'Brave-browser']
define_keymap(
    name='Chromium tab control',
    condition=is_chromium,
    mappings={
        K('Super-w'): K('C-F4'),
        K('Super-Shift-w'): K('M-F4'),
        K('Super-Shift-t'): K('C-Shift-t'),
        K('Super-Shift-i'): K('F12')}
)
# define_conditional_modmap(
#     condition=is_chromium,
#     mod_remappings={
#         Key.LEFT_META: Key.LEFT_CTRL,
#         Key.RIGHT_META: Key.RIGHT_CTRL}
# )


# Remap Ctrl-[key] to Super-[key]
define_keymap(
    name='Super keys',
    condition=None,
    mappings={K(f'Super-{k}'): K(f'Ctrl-{k}') for k in 'acfnrvpwtxz'}
)


# Emacs-like keybindings
define_keymap(
    name='Emacs-like',
    condition=lambda wm_class: not is_terminal(wm_class),
    mappings={
        # Cursor
        K("C-b"): K("left"),
        K("C-f"): K("right"),
        K("C-p"): K("up"),
        K("C-n"): K("down"),
        # Forward/Backward word
        K("C-M-b"): K("C-left"),
        K("C-M-f"): K("C-right"),
        # Beginning/End of line
        K("C-a"): K("home"),
        K("C-e"): K("end"),
        # Page up/down
        # K("M-v"): K("page_up"),
        K("C-v"): K("page_down"),
        # Newline
        K("C-m"): K("enter"),
        K("C-j"): K("enter"),
        # Delete
        K("C-h"): K("backspace"),
        K("C-d"): K("delete"),
        # Esc
        K('C-right_brace'): K('esc'),  # for JIS keyboard
        K('C-left_brace'): K('esc'),   # for US keyboard
    }
)
