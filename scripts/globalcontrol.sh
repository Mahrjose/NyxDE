#!/usr/bin/env bash

export confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
export nyxdeConfDir="${confDir}/NyxDE"

export cacheDir="$HOME/.cache/NyxDE"
export thumbDir="${cacheDir}/thumbs"
export dynamicColorDir="${cacheDir}/dcolors"

export hashAlgorithm="sha1sum"

generateWallpaperHash() {
    
    unset wallpaperHash         # Array for storing wallpaper Hash
    unset wallpaperList         # Array for storing wallpaper names
    unset verboseMode           # OPTIONAL - arg to set verbose mode
    unset skipStrays            # OPTIONAL - 
    
    for wallpaperDir in "$@"; do
        [ -z "${wallpaperDir}" ] \
        && continue
        
        [ "${wallpaperDir}" == "--skipstrays" ] \
        && skipStrays=1 \
        && contine
        
        [ "${wallpaperDir}" == "--verbose" ] \
        && verboseMode=1 \
        && continue
        
        hashMap=$(find "${wallpaperDir}" -type f \( \
            -iname "*.gif"  -o \
            -iname "*.png"  -o \
            -iname "*.jpg"  -o \
            -iname "*.jpeg" \
        \) -exec "${hashAlgorithm}" {} + | sort -k2)
        
        if [ -z "${hashMap}" ]; then
            echo "WARNING: No image found in \"${wallpaperDir}\""
            continue
        fi
        
        while read -r hash image; do
            wallpaperHash+=("${hash}")
            wallpaperList+=("${image}")
        done <<< "${hashMap}"
    done

    if [[ "${#wallpaperList[@]}" -eq 0 ]]; then
        if [[ "${skipStrays}" -eq 1 ]]; then
            return 1
        else
            echo "ERROR: No image found in any source"
            exit 1
        fi
    fi
    
    if [[ "${verboseMode}" -eq 1 ]]; then
        echo "------------------// Hash Map //------------------"
        echo "Hash Algorithm  : ${hashAlgorithm}"
        echo "Image Directory : ${wallpaperDir}"
        echo "Images Processed: ${#wallpaperList[@]}"
        echo "--------------------------------------------------"
        for index in "${!wallpaperHash[@]}"; do
            echo ":: \${wallpaperHash[$index]}=\"${wallpaperHash[$index]}\" :: \${wallpaperList[$index]=\"${wallpaperList[$index]}\""
        done
        echo "--------------------------------------------------"
    fi
}