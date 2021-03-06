#!/bin/bash

BG="#2E3440"
FG="ffffff"

# Options
width="500"
height="30"
font="Helvetica Neue-9"
 
# Get monitor width so we can center the bar.
resolution="$(xrandr --nograb --current | awk '/\*/ {printf $1; exit}')"
monitor_width="${resolution/x*}"
monitor_height="${resolution#*x}"
offset_height="$((monitor_height - height - 5))"
geometry="${width}x${height}+0+${offset_height}"
 
HEIGHT=70
AppWidth=100
WSWidth=290
BatWidth=70
TimeWidth=80
MPDWidth=255
WsPos=0 
ModDist=10

bspc config top_padding 40

# find dimensions of monitor
WIDTH=$( xdpyinfo  | grep -i 'dimensions:' | sed 's:x:\ :' | awk '{print $2}' ) 
#HEIGHT=$( xdpyinfo  | grep -i 'dimensions:' | sed 's:x:\ :' | awk '{print $3}' ) 

#Calculate position of modules.
APPPOS=$(expr "$WIDTH" / 2 - $AppWidth / 2 )
TimePos=$(expr "$WIDTH" - $ModDist - $TimeWidth) 
BatPos=$(expr "$TimePos" - $BatWidth - $ModDist) 
MPDPos=$(expr "$BatPos" - $MPDWidth - $ModDist) 
mpd_status() {
  status=$(mpc | sed -n 2p | awk -F " " '{print $1}')
  output1=$(mpc | tail -1 | cut -f1 -d " " --complement )
  
  string=""
  
  # repeat
  repeattail=$(echo $output1 | sed 's/^.*repeat/repeat/')
  repeat=${repeattail% random*}
  if [[ $repeat == "repeat: on" ]]; then string="$string"r ; else string="$string-" ; fi
  
  # random
  randomtail=$(echo $output1 | sed 's/^.*random/random/')
  random=${randomtail% single*}
  if [[ $random == "random: on" ]]; then string="$string z"; else string="$string -" ; fi
  
  # single
  singletail=$(echo $output1 | sed 's/^.*single/single/')
  single=${singletail% consume*}
  if [[ $single == "single: on" ]]; then string="$string s" ; else string="$string -" ; fi
  
  # consume
  consume=$(echo $output1 | sed 's/^.*consume/consume/')
  if [[ $consume == 'consume: on' ]]; then string="$string c" ; else string="$string -" ; fi
  
  # crossfade
  crossfade=$(mpc crossfade)
  if [[ "$crossfade" == "crossfade: 0" ]]; then string="$string -" ; else string="$string x" ; fi

  # output
  if [[ $status == '[playing]' ]] ; then
    nowplaying=$(mpc current | cut -c -70)
    timer=$(mpc | sed -n 2p | awk -F " " '{print $3}')
    echo "$nowplaying   %{r}  [$string -] [ $timer ]   "
  elif [[ $status == '[paused]' ]] ; then
    nowplaying=$(mpc current | cut -c -60)
    echo "$nowplaying   %{r}  [$string -] [ paused ]   "
  else
    echo "mpd is not active"
  fi
}

spotify_status() {
  thispid=$(pidof spotify)
  if [[ -n $thispid ]]; then
    song=$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep title -A 1 |tail -n 1 |cut -c 43- | sed 's/"//g' | cut -c -60)
    artist=$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep albumArtist -A 2 | tail -n 1 | cut -c 26- | awk '{gsub("\"", "");print}')
    echo "$artist - $song"
  else
    echo "Spotify is not active"
  fi
}
 
while true; do
  if [[ $(spotify_status) != "Spotify is not active" ]] ; then
    echo -e "%{c}%{F#EA7866}%{F#98CD97}\uf1bc%{F-}    $(spotify_status)%{F-}"
  elif [[ $(mpd_status) != "mpd is not active" ]] ; then
    echo -e "%{l}%{F#EA7866}   \uf001    $(mpd_status)%{F-}"
  else
    echo -e "%{c}%{F#EA7866}No music players active%{F-}"
  fi
  sleep 1
done | lemonbar -d -g $MPDWidth\x30+$MPDPos+4 -f "$font" -f "Hack Nerd Font" -f "SoukouMincho-9" -B $BG

