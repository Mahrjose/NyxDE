#!/usr/bin/env bash

generateWallpaperHash() {

    # This function processes a list of directories, generating hashes and paths
    # for each image file found within the directories. The function supports
    # verbose output and skipping directories with no images. Hashes and paths
    # are stored in wallpaperHash and wallpaperList arrays, respectively.
    #
    # Parameters:
    # - $@: List of directory paths to process.
    # - --verbose: Enables verbose mode for additional output.
    # - --skipstrays: Skips directories with no images.
    #
    # Returns:
    # - 1 if no images are found and --skipstrays is enabled.
    # - Exits with error if no images are found and --skipstrays is not enabled.
    # - Otherwise, stores image hashes and paths in the corresponding arrays.

    unset wallpaperHash # Array to store hashes of wallpapers
    unset wallpaperList # Array to store file paths of wallpapers
    unset verboseMode   # Flag to enable verbose output (default: off)
    unset skipStrays    # Flag to skip processing directories with no images (default: off)

    # Loop through all provided directories
    for wallpaperDir in "$@"; do

        # Check if the directory path is empty or not provided
        [ -z "${wallpaperDir}" ] &&
            continue

        # Check for special flags in arguments
        [ "${wallpaperDir}" == "--skipstrays" ] &&
            skipStrays=1 &&
            continue

        [ "${wallpaperDir}" == "--verbose" ] &&
            verboseMode=1 &&
            continue

        # Generate a sorted list of file hashes and their paths
        hashMap=$(find "${wallpaperDir}" -type f \( \
            -iname "*.gif" -o \
            -iname "*.png" -o \
            -iname "*.jpg" -o \
            -iname "*.jpeg" \
            \) -exec "${hashAlgorithm}" {} + | sort -k2)

        # Check if no images were found and handle accordingly
        if [ -z "${hashMap}" ]; then
            echo "WARNING: No image found in \"${wallpaperDir}\""
            continue
        fi

        # Read each line from hashMap and populate arrays
        while read -r hash image; do
            wallpaperHash+=("${hash}")
            wallpaperList+=("${image}")
        done <<<"${hashMap}"
    done

    # Check if no wallpapers were processed
    if [[ "${#wallpaperList[@]}" -eq 0 ]]; then
        if [[ "${skipStrays}" -eq 1 ]]; then
            return 1
        else
            echo "ERROR: No image found in any source"
            exit 1
        fi
    fi

    # Verbose output for debugging purposes
    if [[ "${verboseMode}" -eq 1 ]]; then
        echo "======> // Hash Map // <======"
        echo "Hash Algorithm  : ${hashAlgorithm}"
        echo "Image Directory : ${wallpaperDir}"
        echo "Images Processed: ${#wallpaperList[@]}"
        echo "--------------------------------------------------"
        for index in "${!wallpaperHash[@]}"; do
            echo ":: \${wallpaperHash[$index]}=\"${wallpaperHash[$index]}\" :: \${wallpaperList[$index]}=\"${wallpaperList[$index]}\""
        done
        echo "--------------------------------------------------"
        echo ""
    fi
}

setWallpaperHash() {

    # This function calculates the hash of a given wallpaper file using the
    # specified hash algorithm.
    #
    # Parameters:
    # - $1: The file path of the wallpaper to hash.
    #
    # Returns:
    # - The hash value of the wallpaper.

    local wallpaper="${1}"
    "${hashAlgorithm}" "${wallpaper}" | awk '{print $1}'
}

generateThemeList() {

    # This function generates a list of themes, sorting them based on their
    # order. It ensures that wallpaper symlinks are correct and collects
    # theme names, orders, and corresponding wallpapers into arrays.
    #
    # Parameters:
    # - $1: Optional --verbose flag to enable verbose output.
    #
    # Returns:
    # - Populates sortedThemeOrderList, sortedThemeList, and sortedWallpaperList
    #   with ordered themes and their wallpapers.

    unset themeOrderList # Array to store theme sort orders
    unset themeList      # Array to store theme names
    unset wallpaperList  # Array to store wallpaper paths

    unset sortedThemeOrderList # Sorted array of theme sort orders
    unset sortedThemeList      # Sorted array of theme names
    unset sortedWallpaperList  # Sorted array of wallpaper paths

    themeOrder=1 # Counter for theme order / serial

    while read -r themeDir; do

        # Check if the symlink for wallpaper is missing or broken & fix them
        if [ ! -e "$(readlink "${themeDir}/wallpaper.set")" ]; then

            generateWallpaperHash --skipstrays "${themeDir}" ||
                continue

            # Create or update the symlink to the current wallpaper
            echo "Fixing wallpaper symlink :: ${themeDir}/wallpaper.set -> ${wallpaperList[0]}"
            ln -fs "${wallpaperList[0]}" "${themeDir}/wallpaper.set"
        fi

        # Read the theme order from file
        if [ -f "${themeDir}/.themeOrder" ]; then
            themeOrderList+=("$(head -1 "${themeDir}/.themeOrder")")
        else
            if echo $themeOrder >"${themeDir}/.themeOrder"; then
                themeOrderList+=("${themeOrder}")
                ((themeOrder++))
            else
                echo "Error: Unable to write to ${themeDir}/.themeOrder" >&2
            fi
        fi

        themeList+=("$(basename "${themeDir}")")
        wallpaperList+=("$(readlink "${themeDir}/wallpaper.set")")

    done < <(find "${nyxdeConfDir}/themes" -mindepth 1 -maxdepth 1 -type d)

    # Combine the theme lists into a sorted list
    while IFS='|' read -r order theme wallpaper; do
        sortedThemeOrderList+=("${order}")
        sortedThemeList+=("${theme}")
        sortedWallpaperList+=("${wallpaper}")
    done < <(parallel --link echo "{1}\|{2}\|{3}" ::: "${themeOrderList[@]}" ::: "${themeList[@]}" ::: "${wallpaperList[@]}" | sort -n -k 1 -k 2)

    # Verbose output for debugging purposes
    if [ "${1}" == "--verbose" ]; then
        echo "======> // Theme Debug // <======"
        echo "Theme Directory : ${nyxdeConfDir}/themes"
        echo "Themes Processed: ${#sortedThemeList[@]}"
        echo "--------------------------------------------------"
        for index in "${!sortedThemeList[@]}"; do
            echo -e ":: \${sortedThemeOrderList[${index}]}=\"${sortedThemeOrderList[index]}\" :: \${sortedThemeList[${index}]}=\"${sortedThemeList[index]}\" :: \${sortedWallpaperList[${index}]}=\"${sortedWallpaperList[index]}\""
        done
        echo "--------------------------------------------------"
        echo ""
    fi
}

isPackageInstalled() {

    # Checks if a given package is installed on the system, either through
    # Pacman, Flatpak, or if the package's command is available in the PATH.
    #
    # Parameters:
    # - $1: The name of the package to check.
    #
    # Returns:
    # - 0 if the package is installed.
    # - 1 if the package is not installed.

    local packageName=$1

    if pacman -Qi "${packageName}" &>/dev/null; then
        return 0
    fi

    if pacman -Qi "flatpak" &>/dev/null && flatpak info "${packageName}" &>/dev/null; then
        return 0
    fi

    # Checking if the command is available in the system's PATH
    if command -v "${packageName}" &>/dev/null; then
        return 0
    fi

    echo "Package '${packageName}' is not installed or not found." >&2
    return 1
}

updateConfig() {

    # This function updates a key-value pair in the NyxDE configuration file.
    # If the key exists, its value is updated; if not, the key-value pair is
    # added to the configuration file.
    #
    # Parameters:
    # - $1: The key to update or add.
    # - $2: The value to associate with the key.
    #
    # Returns:
    # - None

    local configKey="${1}"
    local configValue="${2}"

    touch "${nyxdeConfDir}/nyxde.conf"

    if [[ $(grep -c "^${configKey}=" "${nyxdeConfDir}/nyxde.conf") -eq 1 ]]; then
        sed -i "/^${configKey}=/c${configKey}=\"${configValue}\"" "${nyxdeConfDir}/nyxde.conf"
    else
        echo "${configKey}=\"${configValue}\"" >>"${nyxdeConfDir}/nyxde.conf"
    fi
}

main() {

    export confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
    export nyxdeConfDir="${confDir}/NyxDE"

    export cacheDir="$HOME/.cache/NyxDE"
    export thumbDir="${cacheDir}/thumbs"
    export dynamicColorDir="${cacheDir}/dcolors"

    export hashAlgorithm="sha1sum"

    if [ -f "${nyxdeConfDir}/hyde.conf" ]; then
        source "${nyxdeConfDir}/nyxde.conf"
    fi

    case "${enableWallDColor}" in 0 | 1 | 2 | 3) ;;
    *) enableWallDColor=0 ;;
    esac

    if [ -z "${nyxdeTheme}" ] || [ ! -d "${nyxdeConfDir}/themes/${nyxdeTheme}" ]; then
        generateThemeList
        nyxdeTheme=${sortedThemeList[0]}
    fi

    export nyxdeTheme
    export nyxdeThemeDir="${nyxdeConfDir}/themes/${nyxdeTheme}"
    export wallbashDir="${nyxdeConfDir}/wallbash"
    export enableWallDColor

    if printenv HYPRLAND_INSTANCE_SIGNATURE &>/dev/null; then
        hypr_border="$(hyprctl -j getoption decoration:rounding | jq '.int')"
        export hypr_border

        hypr_width="$(hyprctl -j getoption general:border_size | jq '.int')"
        export hypr_width
    fi
}

# execute the script
main
