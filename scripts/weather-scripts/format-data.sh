#! /usr/bin/env bash

# formatData() {

#     # formatData: Formats and prepares weather information for display.
#     # Extracts and formats details such as location, temperature, wind, and more.
#     # Arguments:
#     #   json         : JSON data containing weather details      (required)
#     #   locationInfo : JSON data containing location information (required)
#     # Returns:
#     #   JSON string with formatted weather text and tooltip for display.

#     local json="$1"         # Json data, includes various weather info
#     local locationInfo="$2" # Json data, includes city, lat, lon, country, state
#     local hourlyForecast="$3"
#     local multiDayForecast="$4"

#     # --------------------------------------------------------------------- #
#     # Extract and format location data (latitude, longitude, city, country) #
#     # ----------------------------------------------------------------------#

#     local lat
#     local lon
#     lat=$(printf "%.3f" "$(jq -r '.lat' <<<"$locationInfo")")
#     lon=$(printf "%.3f" "$(jq -r '.lon' <<<"$locationInfo")")

#     local city
#     local country
#     local flag
#     city=$(jq -r '.name' <<<"$locationInfo")
#     country=$(getCountryName "$(jq -r '.sys.country' <<<"$json")")
#     flag=$(getFlagEmoji "$(jq -r '.sys.country' <<<"$json")")

#     # ----------------------------------------------------------------------#
#     #         Extract and format temperature and weather description        #
#     # ----------------------------------------------------------------------#

#     local temperature
#     local feelsLike
#     local tempMin
#     local tempMax
#     local weatherDescription
#     temperature=$(printf "%.1f" "$(jq -r '.main.temp' <<<"$json")")
#     feelsLike=$(printf "%.1f" "$(jq -r '.main.feels_like' <<<"$json")")
#     weatherDescription=$(jq -r '.weather[0].description' <<<"$json")

#     tempMin=$(printf "%.1f" "$(jq -r '.temp_min' <<<"$hourlyForecast")")
#     tempMax=$(printf "%.1f" "$(jq -r '.temp_max' <<<"$hourlyForecast")")

#     # ----------------------------------------------------------------------#
#     #  Extract and format wind data (speed, direction, gusts) and humidity  #
#     # ----------------------------------------------------------------------#

#     local humidity
#     local windSpeed
#     local windDirection
#     local windGusts
#     humidity=$(jq -r '.main.humidity' <<<"$json")
#     windSpeed=$(jq -r '.wind.speed' <<<"$json")
#     windDirection=$(getDirectionEmoji "$(jq -r '.wind.deg' <<<"$json")")
#     windGusts=$(jq -r '.wind.gust // 0' <<<"$json")

#     # ----------------------------------------------------------------------------------#
#     # Extract and format additional weather details (pressure, cloud cover, visibility) #
#     # ----------------------------------------------------------------------------------#

#     local pressure
#     local cloudCover
#     local visibility
#     pressure=$(jq -r '.main.pressure' <<<"$json")
#     cloudCover=$(jq -r '.clouds.all' <<<"$json")
#     visibility=$(($(jq -r '.visibility' <<<"$json") / 1000)) # Convert meters to km

#     # ----------------------------------------------------------------------#
#     #             Extract and format sunrise and sunset times               #
#     # ----------------------------------------------------------------------#

#     local sunrise
#     local sunset
#     sunrise=$(jq -r '.sys.sunrise' <<<"$json")
#     sunset=$(jq -r '.sys.sunset' <<<"$json")

#     # ----------------------------------------------------------------------#
#     #     Determine appropriate weather icon and construct display text     #
#     # ----------------------------------------------------------------------#

#     local icon
#     local text
#     local iconCode
#     iconCode=$(jq -r '.weather[0].icon' <<<"$json")
#     icon=$(getWeatherIcon "$iconCode")
#     text="$icon ${temperature}°C"

#     # ----------------------------------------------------------------------#
#     #        Generate a dynamic message based on weather conditions         #
#     # ----------------------------------------------------------------------#

#     local weatherID
#     local message
#     weatherID=$(jq -r '.weather[0].id' <<<"$json")
#     message=$(generateDynamicMessage "$temperature" "$feelsLike" "$weatherID")

#     # ----------------------------------------------------------------------#
#     #              Construct tooltip with all formatted data                #
#     # ----------------------------------------------------------------------#

#     local toolTip
#     toolTip="\
#     \n\
#     📍 Location: ${city}, $country $flag (${lat}, $lon)\n\
#     \n\
#     🌡️ Current Weather: ${temperature}°C | ${weatherDescription^}\n\
#         🔥 Feels Like: ${feelsLike}°C\n\
#         🔼 High: ${tempMax}°C, 🔽 Low: ${tempMin}°C\n\
#     \n\
#     📊 Additional Details:          \n\
#         💧 Humidity   : ${humidity}%   \n\
#         🌬️ Wind       : ${windSpeed} km/h | Direction ${windDirection}   \n\
#         🌪️ Wind Gusts : ${windGusts} km/h    \n\
#         ☁️ Cloud      : ${cloudCover}%      \n\
#         👀 Visibility : ${visibility} km     \n\
#         📊 Pressure   : ${pressure} hPa        \n\
#     \n\
#     🌅 Sunrise: $(date -d @$sunrise +'%I:%M %p') 🌄 | Sunset: $(date -d @$sunset +'%I:%M %p') 🌃    \n\
#     \n\
#     $message \n\
#     "

#     # Return the final JSON string with formatted text and tooltip
#     echo "{\"text\":\"$text\", \"tooltip\":\"$toolTip\"}"
# }

formatData() {

    # formatData: Formats and prepares weather information for display.
    # Extracts and formats details such as location, temperature, wind, and more.
    # Arguments:
    #   json              : JSON data containing weather details      (required)
    #   locationInfo      : JSON data containing location information (required)
    #   hourlyForecast    : JSON data containing hourly forecast      (required)
    #   multiDayForecast  : JSON data containing multi-day forecast   (required)
    # Returns:
    #   JSON string with formatted weather text and tooltip for display.

    local json="$1"             # Json data, includes various weather info
    local locationInfo="$2"     # Json data, includes city, lat, lon, country, state
    local hourlyForecast="$3"   # Hourly forecast JSON data
    local multiDayForecast="$4" # Multi-day forecast JSON data

    # --------------------------------------------------------------------- #
    # Extract and format location data (latitude, longitude, city, country) #
    # --------------------------------------------------------------------- #

    local lat
    local lon
    lat=$(printf "%.3f" "$(jq -r '.lat' <<<"$locationInfo")")
    lon=$(printf "%.3f" "$(jq -r '.lon' <<<"$locationInfo")")

    local city
    local country
    local flag
    city=$(jq -r '.name' <<<"$locationInfo")
    country=$(getCountryName "$(jq -r '.sys.country' <<<"$json")")
    flag=$(getFlagEmoji "$(jq -r '.sys.country' <<<"$json")")

    # ---------------------------------------------------------------------- #
    #         Extract and format temperature and weather description        #
    # ---------------------------------------------------------------------- #

    local temperature
    local feelsLike
    local tempMin
    local tempMax
    local weatherDescription
    temperature=$(printf "%.1f" "$(jq -r '.main.temp' <<<"$json")")
    feelsLike=$(printf "%.1f" "$(jq -r '.main.feels_like' <<<"$json")")
    weatherDescription=$(jq -r '.weather[0].description' <<<"$json")

    tempMin=$(printf "%.1f" "$(jq -r '.temp_min' <<<"$hourlyForecast")")
    tempMax=$(printf "%.1f" "$(jq -r '.temp_max' <<<"$hourlyForecast")")

    # ---------------------------------------------------------------------- #
    #  Extract and format wind data (speed, direction, gusts) and humidity  #
    # ---------------------------------------------------------------------- #

    local humidity
    local windSpeed
    local windDirection
    local windGusts
    humidity=$(jq -r '.main.humidity' <<<"$json")
    windSpeed=$(jq -r '.wind.speed' <<<"$json")
    windDirection=$(getDirectionEmoji "$(jq -r '.wind.deg' <<<"$json")")
    windGusts=$(jq -r '.wind.gust // 0' <<<"$json")

    # ---------------------------------------------------------------------------------- #
    # Extract and format additional weather details (pressure, cloud cover, visibility) #
    # ---------------------------------------------------------------------------------- #

    local pressure
    local cloudCover
    local visibility
    pressure=$(jq -r '.main.pressure' <<<"$json")
    cloudCover=$(jq -r '.clouds.all' <<<"$json")
    visibility=$(($(jq -r '.visibility' <<<"$json") / 1000)) # Convert meters to km

    # ---------------------------------------------------------------------- #
    #             Extract and format sunrise and sunset times               #
    # ---------------------------------------------------------------------- #

    local sunrise
    local sunset
    sunrise=$(jq -r '.sys.sunrise' <<<"$json")
    sunset=$(jq -r '.sys.sunset' <<<"$json")

    # ---------------------------------------------------------------------- #
    #     Determine appropriate weather icon and construct display text     #
    # ---------------------------------------------------------------------- #

    local icon
    local text
    local iconCode
    iconCode=$(jq -r '.weather[0].icon' <<<"$json")
    icon=$(getWeatherIcon "$iconCode")
    text="$icon ${temperature}°C"

    # ---------------------------------------------------------------------- #
    #        Generate a dynamic message based on weather conditions         #
    # ---------------------------------------------------------------------- #

    local weatherID
    local message
    weatherID=$(jq -r '.weather[0].id' <<<"$json")
    message=$(generateDynamicMessage "$temperature" "$feelsLike" "$weatherID")

    # ---------------------------------------------------------------------- #
    #                Prepare the daily forecast for the tooltip              #
    # ---------------------------------------------------------------------- #

    local dailyForecast=""
    local timeSlots=("00:00:00" "06:00:00" "12:00:00" "18:00:00")
    for timeSlot in "${timeSlots[@]}"; do
        local temp
        local desc
        temp=$(jq -r --arg time "$timeSlot" '.hours[] | select(.time == $time) | .temp' <<<"$hourlyForecast")
        desc=$(jq -r --arg time "$timeSlot" '.hours[] | select(.time == $time) | .desription' <<<"$hourlyForecast")
        dailyForecast+="\n🕒 ${timeSlot} - ${temp}°C | ${desc^}"
    done

    # ---------------------------------------------------------------------- #
    #             Prepare the 4-day forecast for the tooltip                 #
    # ---------------------------------------------------------------------- #

    local dayForecast=""
    for i in {1..4}; do
        local date
        local temp
        local desc
        date=$(jq -r ".days[$i].date" <<<"$multiDayForecast")
        temp=$(jq -r ".days[$i].temp" <<<"$multiDayForecast")
        desc=$(jq -r ".days[$i].desription" <<<"$multiDayForecast")
        dayForecast+="\n📅 ${date} - ${temp}°C | ${desc^}"
    done

    # ---------------------------------------------------------------------- #
    #              Construct tooltip with all formatted data                #
    # ---------------------------------------------------------------------- #

    local toolTip
    toolTip="\
    📍 Location: ${city}, $country $flag (${lat}, $lon)\n\
    \n\
    🌡️ Current Weather: ${temperature}°C | ${weatherDescription^}\n\
        🔥 Feels Like: ${feelsLike}°C\n\
        🔼 High: ${tempMax}°C, 🔽 Low: ${tempMin}°C\n\
    \n\
    📊 Additional Details:          \n\
        💧 Humidity   : ${humidity}%   \n\
        🌬️ Wind       : ${windSpeed} km/h | Direction ${windDirection}   \n\
        🌪️ Wind Gusts : ${windGusts} km/h    \n\
        ☁️ Cloud      : ${cloudCover}%      \n\
        👀 Visibility : ${visibility} km     \n\
        📊 Pressure   : ${pressure} hPa        \n\
    \n\
    🌅 Sunrise: $(date -d @$sunrise +'%I:%M %p') 🌄 | Sunset: $(date -d @$sunset +'%I:%M %p') 🌃    \n\
    \n\
    📅 **Today's Forecast**: \n\
    ${dailyForecast}\n\
    \n\
    📅 **Next 4 Days**: \n\
    ${dayForecast}\n\
    \n\
    $message \n\
    "

    # Return the final JSON string with formatted text and tooltip
    echo "{\"text\":\"$text\", \"tooltip\":\"$toolTip\"}"
}
