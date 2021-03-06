#!/bin/bash
. "$HOME/.cache/wpgtk.color"
width="300"
height="50"
resolution="$(xrandr --nograb --current | awk '/\*/ {printf $1; exit}')"
monitor_width="${resolution/x*}"
monitor_height="${resolution#*x}"
offset_width="$(( monitor_width / 2 - width / 2 ))"
offset_height="$(( monitor_height / 2 + height ))"
geometry="${width}x${height}+${offset_width}+${offset_height}"

Brightness(){
    light -G \
    |SIZE=12 START="" END="" SEP="" CHAR1="" CHAR2="%{F${background}}%{F-}" mkb
}

while true; do
echo -e "%{l}%{F${foreground}}%{B${background}}   Brightness: $(Brightness) %{F-}%{B-}" && sleep 1.5 && exit
done | lemonbar -d -g $geometry -f "FontAwesome-18" -B "${background}"

