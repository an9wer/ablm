ABLM - an A-B Loop Manager
==========================

ablm is a mpv script for managing A-B loops, with the following features:

- saving and restoring multiple A-B loops for every single video
- replaying and moving between any saved A-B loops
- adjusting (forward/backword) the current A-B loop

Usage
-----

Download the script file *ablm.lua* to mpv's script directory (should be
*~/.config/mpv/scripts* for linux), then use the following keybinds to interact
with A-B loops in mpv:

=============  ===============================
 key            function
=============  ===============================
 Alt-L          save the current A-B loop
 Ctrl-L         load the next A-B loop
 Ctrl-Shift-L   load the previous A-B loop
 Ctrl-Left      backward the current loop A
 Ctrl-Right     forward the current loop A
 Alt-Left       backward the current loop B
 Alt-Right      forward the current loop B
=============  ===============================
