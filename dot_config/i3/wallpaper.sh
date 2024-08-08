#! /bin/zsh

target=$1
dir="$HOME/Pictures/wallpaper/"$target
file=$(ls $dir | shuf -n1)
feh --bg-max "$dir/$file"
