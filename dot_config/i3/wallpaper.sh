#! /bin/zsh

dir="$HOME/Pictures/wallpaper"
file=$(ls $dir | shuf -n1)
feh --bg-max "$dir/$file"
