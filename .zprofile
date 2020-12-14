#!/bin/sh

export XDG_CONFIG_HOME=/home/mknight/.config

echo UPDATESTARTUPTTY | gpg-connect-agent

if [ $(tty) = "/dev/tty1" ]
then
	export BEMENU_BACKEND=wayland
	export XDG_SESSION_TYPE=wayland
	export XDG_CURRENT_DESKTOP=sway
	river -c ~/.config/river/config.sh
fi
