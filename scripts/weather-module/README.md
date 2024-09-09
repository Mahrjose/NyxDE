# Weather Module

This weather module is a set of shell scripts designed to fetch and display weather information using APIs like VisualCrossing and OpenWeather. It is intended for integration into larger projects or used independently for fetching real-time weather conditions, detailed forecasts, and generating dynamic weather messages. The module is designed for lightweight desktop environment integrations, such as Waybar.

## Table of Contents
1. [Features](#features)
2. [Setup](#setup)
3. [Dependencies](#dependencies)
4. [Usage](#usage)
    - [Hourly Weather Forecast](#hourly-weather-forecast)
    - [Multi-Day Weather Forecast](#multi-day-weather-forecast)
    - [Icons and Emojis](#icons-and-emojis)
    - [Dynamic Messages](#dynamic-messages)
5. [Scripts](#scripts)
6. [Configuration](#configuration)

## Features

- **Hourly Weather Forecasts**: Get real-time hourly weather data for any location.
- **Multi-Day Forecast**: Fetch weather forecasts for the next several days.
- **Weather Icons and Emojis**: Display relevant weather icons, directional emojis, and flags.
- **Dynamic Weather Messages**: Generate contextual advisory messages based on weather conditions.
- **Location-Based Search**: Support for city/state/country or latitude/longitude-based location lookups.
- **Self-contained**: No external dependencies, ideal for lightweight desktop environment integrations.

## Setup

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/mahrjose/nyxdots.git
   cd scripts/weather-module
   ```
   
2. **Install Required Dependencies**:
   This module depends on utilities like `curl`, `jq`, and `bc` for fetching and processing data. Install them as follows:

   - On Debian/Ubuntu-based systems:
     ```bash
     sudo apt-get install curl jq bc
     ```

   - On Arch-based systems:
     ```bash
     sudo pacman -S curl jq bc
     ```

3. **API Keys**:
   - Obtain API keys from:
     - [Visual Crossing Weather API](https://www.visualcrossing.com/)
     - [OpenWeatherMap Geo API](https://openweathermap.org/api/geocoding-api)

   Store them in a `.env` file located in the root of the module directory:

   ```bash
   VISUALCROSSING_APIKEY=your_visualcrossing_api_key
   OPENWEATHER_APIKEY=your_openweathermap_api_key
   ```
## Dependencies

This module requires the following dependencies to be installed:

- `curl` - Used for making API requests.
- `jq` - Used for parsing JSON responses.
- `bc` - Used for floating-point arithmetic in the shell scripts.

## Usage

### Hourly Weather Forecast

To get the hourly weather forecast for a specific location:

```bash
./weather-forecast.sh --hourly --city "CityName" --state "StateName" --country "CountryName"
```

You can also use coordinates:

```bash
./weather-forecast.sh --hourly --lat 40.7128 --lon -74.0060
```

### Multi-Day Weather Forecast

To get a multi-day weather forecast:

```bash
./weather-forecast.sh --multidays --city "CityName" --state "StateName" --country "CountryName"
```

### Icons and Emojis

You can retrieve weather icons, country flags, and directional emojis with the following commands:

- **Weather Icons**: Use the `getWeatherIcon` function to map weather codes to corresponding emoji icons.
  ```bash
  ./weather-utils.sh getWeatherIcon "01d" # returns ☀️ for clear skies during the day
  ```
- **Country Flags**: Use the `getFlagEmoji `function to retrieve the flag emoji for a given ISO country code.

  ```bash
  ./weather-utils.sh getFlagEmoji "US" # returns 🇺🇸 for the United States
  ```
- **Directional Emojis**: Use the `getDirectionEmoji` function to convert wind degrees into directional emojis.
  ```bash
  ./weather-utils.sh getDirectionEmoji 180 # returns ⬇️ for South
  ```

### Dynamic Messages

Generate contextual messages based on temperature and weather conditions:

```bash
./generate-weather-messages.sh generateDynamicMessage 30 500 # returns "Hot weather. Suitable for indoor activities. Light rain..."
```

## Scripts

- **`run.sh`**: Main entry point for fetching weather data.
  - **Description**: Gathers and displays weather data from various APIs.
  - **Usage**:
    ```bash
    ./run.sh [options]
    ```
  - **Options**:
    - `--current`: Fetch current weather conditions.
    - `--hourly`: Fetch hourly forecast.
    - `--daily`: Fetch multi-day forecast.

- **`weather-forecast.sh`**: Handles fetching weather forecasts (hourly and multi-day).
  - **Functions**:
    - `hourlyWeatherForecast`: Fetches and parses hourly weather data.
    - `multiDayWeatherForecast`: Fetches multi-day forecasts.
    - `getWeatherForecast`: Wrapper function to call either `hourly` or `multiday` forecasts.

- **`weather-utils.sh`**: Contains utility functions for handling weather-related data.
  - **Functions**:
    - `getWeatherIcon`: Maps weather codes to corresponding emoji icons.
    - `getCountryName`: Retrieves the full country name from a JSON file using ISO codes.
    - `getFlagEmoji`: Retrieves the flag emoji from the ISO country code.
    - `getDirectionEmoji`: Converts wind degrees into directional emojis.

- **`get-location.sh`**: Fetches location data based on city/state/country or latitude/longitude coordinates.
  - **Usage**:
    ```bash
    ./get-location.sh --by-city --city <city-name> [--state <state>] [--country <country>]
    ./get-location.sh --by-coordinates --lat <latitude> --lon <longitude>
    ```

- **`generate-weather-messages.sh`**: Generates weather advisories based on "feels-like" temperature and weather conditions.
  - **Usage**:
    ```bash
    ./generate-weather-messages.sh generateDynamicMessage <feels-like-temperature> <weather-id>
    ```

- **`config.env`**: Contains environment variables such as API keys.


## Configuration

To customize the script for your use case, modify the following environment variables and script parameters:

- **API Keys**: Store your API keys in a `.env` file as mentioned in the [Setup](#setup) section.
- **Units**: The weather data is fetched in metric units by default. Modify the units by changing the `unitGroup` parameter in `weather-forecast.sh`.