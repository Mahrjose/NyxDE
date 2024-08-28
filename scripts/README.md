# Script Directory Documentation

Welcome to the `scripts` directory of the **NyxDE** project! This directory contains various Bash scripts that automate and manage different aspects of your system's appearance, behavior, and configurations. Below, you'll find detailed explanations of what each script does, along with how to use them.

## Table of Contents

- [fetch-weather.sh](#fetch-weathersh)
- [globalcontrol.sh](#globalcontrolsh)

---

### fetch-weather.sh

**Purpose**:  
`fetch-weather.sh` is a script designed to fetch and display the current weather for a specified location. It interacts with the `wttr.in` service to retrieve both simple and detailed weather information, which is then formatted and output as a JSON string.

**Features**:
- Fetches basic weather data (e.g., temperature, condition) as well as detailed information (e.g., wind, precipitation).
- Cleans up the data for better readability, including removing unwanted symbols and formatting the location.
- Attempts to fetch the weather up to 5 times in case of failure, ensuring reliability.

**Usage**:
```bash
./fetch-weather.sh "New+York"
```

**Example Output**:
```json
{"text":"☁️ 25°C", "tooltip":"New York: 🌧️ Light rain, 25°C"}
```

---

### globalcontrol.sh

**Purpose**:  
`globalcontrol.sh` is the heart of the **NyxDE** configuration management. It handles various tasks such as generating wallpaper hashes, managing theme lists, and updating configuration files.

**Features**:
- **generateWallpaperHash**: Scans directories for image files, generating hashes and paths, which are stored in arrays. Supports verbose output and the option to skip directories with no images.
- **setWallpaperHash**: Calculates the hash of a specified wallpaper using a chosen hash algorithm.
- **generateThemeList**: Creates a sorted list of themes, ensuring correct symlinks for wallpapers and collecting theme data into arrays.
- **updateConfig**: Updates or adds key-value pairs in the **NyxDE** configuration file.
- **isPackageInstalled**: Checks if a package is installed on the system via Pacman, Flatpak, or if its command is available.
- **findAurHelper**: Identifies the AUR helper (like `paru` or `yay`) installed on the system.

**Usage**:
- **Generate Wallpaper Hashes**:
  ```bash
  ./globalcontrol.sh generateWallpaperHash ~/Pictures/Wallpapers --verbose
  ```
- **Generate Theme List**:
  ```bash
  ./globalcontrol.sh generateThemeList --verbose
  ```

**Notes**:
- This script relies on environment variables for configuration directories, theme settings, and more. Ensure that these are correctly set before running the script.

---

### How to Use the Scripts

To execute any of these scripts, simply navigate to the `scripts` directory in your terminal and run the desired script with the appropriate arguments.

```bash
cd /path/to/your/scripts/directory
./script_name.sh [arguments]
```

### Contributing

If you'd like to contribute to the development or improvement of these scripts, feel free to fork the project and submit a pull request. Contributions, whether in the form of bug reports, feature requests, or code, are always welcome!

---

This documentation will help you understand and utilize the scripts in the **NyxDE** project effectively. If you encounter any issues or have further questions, feel free to reach out or consult the project's main documentation.