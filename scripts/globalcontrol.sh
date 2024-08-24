#!/usr/bin/env bash

export confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
export hydeConfDir="${confDir}/NyxDE"

export cacheDir="$HOME/.cache/NyxDE"
export thumbDir="${cacheDir}/thumbs"
export dcolDir="${cacheDir}/dcols"

export hashAlgorithm="sha1sum"

get_hashmap() {
    
    unset wallpaperHash
    unset wallpaperList
    unset skipStrays
    unset verboseMap
    
    for wallpaper_src in "$@"; do
        [ -z "${wallpaper_src}" ] \
        && continue
        
        [ "${wallpaper_src}" == "--skipstrays" ] \
        && skipStrays=1 \
        && contine
        
        [ "${wallpaper_src}" == "--verbose" ] \
        && verboseMap=1 \
        && continue
        
        hashMap=$(find "${wallpaper_src}" -type f \( \
            -iname "*.gif"  -o \
            -iname "*.png"  -o \
            -iname "*.jpg"  -o \
            -iname "*.jpeg" -o \
        \) -exec "${hashAlgorithm}" {} + | sort -k2)
        
        if [ -z "${hashMap}" ]; then
            echo "WARNING: No image found in \"${wallpaper_src}\""
            continue
        fi
        
        while read -r hash image; do
            wallpaperHash+=("${hash}")
            wallpaperList+=("${image}")
        done <<< "${hashMap}"
    done

    if [ -z "${#wallpaperList[@]}" ] || [[ "${#wallpaperList[@]}" -eq 0 ]]; then
        if [[ "${skipStrays}" -eq 1 ]]; then
            return 1
        else
            echo "ERROR: No image found in any source"
            exit 1
        fi
    fi
    
}