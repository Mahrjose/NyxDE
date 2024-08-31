#!/usr/bin/env bash

getWeatherIcon() {
    local iconCode="$1"

    case "$iconCode" in
    "01d") echo "☀️" ;;         # clear sky (day)
    "01n") echo "🌑" ;;          # clear sky (night)
    "02d") echo "🌤️" ;;         # few clouds (day)
    "02n") echo "🌥️" ;;         # few clouds (night)
    "03d" | "03n") echo "☁️" ;; # scattered clouds
    "04d" | "04n") echo "🌥️" ;; # broken clouds
    "09d" | "09n") echo "🌦️" ;; # shower rain
    "10d" | "10n") echo "🌧️" ;; # rain
    "11d" | "11n") echo "⛈️" ;; # thunderstorm
    "13d" | "13n") echo "❄️" ;; # snow
    "50d" | "50n") echo "🌫️" ;; # mist
    *) echo "❓" ;;              # unknown weather condition
    esac
}

generateDynamicMessage() {

    # generateDynamicMessage() generates a professional weather message based on the provided temperature,
    # feels-like temperature, and weather ID, with a focus on the climate of Bangladesh.
    # Arguments:
    #   $1: Temperature (in Celsius)
    #   $2: Feels-like temperature (in Celsius)
    #   $3: Weather ID (e.g., 500 for light rain, 800 for clear sky)
    # Returns:
    #   Echoes a weather message based on the provided conditions.

    local temperature="$1"
    local feelsLike="$2"
    local weatherID="$3"
    local message=""

    if (($(echo "$feelsLike > 45" | bc -l))); then
        message="Extreme heat conditions. Outdoor activities are not recommended."
    elif (($(echo "$feelsLike > 40" | bc -l))); then
        message="Very hot. Limit outdoor exposure, and stay hydrated."
    elif (($(echo "$feelsLike > 30" | bc -l))); then
        message="Hot weather. Suitable for indoor activities."
    elif (($(echo "$feelsLike >= 23" | bc -l))); then
        message="Warm and typical weather for this season."
    elif (($(echo "$feelsLike >= 15" | bc -l))); then
        message="Cool weather. Light layers are advisable."
    elif (($(echo "$feelsLike >= 5" | bc -l))); then
        message="Cold weather. Warm clothing is recommended."
    else
        message="Very cold. It's advisable to stay indoors and keep warm."
    fi

    case "$weatherID" in
    200 | 201 | 202)
        message="$message Thunderstorm with rain. Expect heavy rainfall and possible lightning."
        ;;
    210 | 211 | 212)
        message="$message Thunderstorm expected. Heavy rainfall and strong winds possible."
        ;;
    221)
        message="$message Ragged thunderstorm. Be cautious of uneven weather conditions."
        ;;
    230 | 231 | 232)
        message="$message Thunderstorm with drizzle. Rainfall might vary in intensity."
        ;;
    300 | 301)
        message="$message Light drizzle. Roads may be slippery."
        ;;
    302)
        message="$message Heavy drizzle. Reduced visibility on roads."
        ;;
    310 | 311)
        message="$message Light rain with drizzle. Keep an umbrella handy."
        ;;
    312 | 313)
        message="$message Heavy rain with drizzle. Potential for localized flooding."
        ;;
    314 | 321)
        message="$message Heavy rain and drizzle. Exercise caution while traveling."
        ;;
    500)
        message="$message Light rain. Suitable for light outdoor activities."
        ;;
    501)
        message="$message Moderate rain. Roads may be slippery, drive with caution."
        ;;
    502 | 503)
        message="$message Heavy rain. Possible waterlogging in low-lying areas."
        ;;
    504)
        message="$message Extreme rain. High risk of flooding, avoid travel if possible."
        ;;
    511)
        message="$message Freezing rain. Unusual for this region, take extreme caution."
        ;;
    520)
        message="$message Light shower rain. A brief period of rain, but roads may be wet."
        ;;
    521 | 522)
        message="$message Shower rain. Expect short, heavy bursts of rain."
        ;;
    531)
        message="$message Ragged shower rain. Irregular rainfall, prepare accordingly."
        ;;
    600)
        message="$message Light snow. Rare occurrence, potential disruptions."
        ;;
    601)
        message="$message Snowfall. Rare in this region, significant disruptions expected."
        ;;
    602)
        message="$message Heavy snow. Unusual and likely to cause major disruptions."
        ;;
    611 | 612 | 613)
        message="$message Sleet expected. Roads may be hazardous."
        ;;
    615 | 616)
        message="$message Mixed rain and snow. Unusual conditions, take precautions."
        ;;
    620 | 621 | 622)
        message="$message Snow showers. Rare, potential for accumulation."
        ;;
    701)
        message="$message Misty conditions. Reduced visibility, drive cautiously."
        ;;
    711)
        message="$message Smoke detected. Possible air quality issues."
        ;;
    721)
        message="$message Hazy weather. Reduced visibility, but no major disruptions expected."
        ;;
    731 | 761)
        message="$message Dust in the air. May cause discomfort, particularly for those with respiratory issues."
        ;;
    741)
        message="$message Foggy conditions. Significantly reduced visibility, drive with extreme caution."
        ;;
    751 | 762)
        message="$message Sand or ash in the air. Unusual, may cause disruptions."
        ;;
    771)
        message="$message Squalls expected. Sudden strong winds, secure loose objects."
        ;;
    781)
        message="$message Tornado warning. Seek shelter immediately."
        ;;
    800)
        message="$message Clear skies. Ideal conditions for outdoor activities."
        ;;
    801)
        message="$message Few clouds. Generally clear, with some cloud cover."
        ;;
    802)
        message="$message Scattered clouds. Partially cloudy, but no major disruptions."
        ;;
    803)
        message="$message Broken clouds. More clouds than sun, but weather remains stable."
        ;;
    804)
        message="$message Overcast skies. Dull conditions, but no precipitation expected."
        ;;
    *)
        message="$message Unusual weather conditions. Stay prepared for unexpected changes."
        ;;
    esac

    local maxLength=8 # Adjust this value according to your desired line length

    local wordCount=0
    local newMessage=""
    local padding="    "

    for word in $message; do
        if ((wordCount == maxLength)); then
            newMessage+="\n$padding"
            wordCount=0
        fi
        newMessage+="$word "
        ((wordCount++))
    done

    message=$newMessage

    echo "📝 $message"
}

getCountryName() {
    local countryCode="$1"
    countryName=$(curl -s "https://restcountries.com/v3.1/alpha/${countryCode}" | jq -r '.[0].name.common')
    echo "$countryName"
}

getFlagEmoji() {

    local flag=$(jq -r --arg code "$1" '.[] | select(.code == $code) | .flag' ./flags.json)
    echo "$flag"
}

getDirectionEmoji() {
    local degree=$1
    local emoji

    if ((degree >= 0 && degree <= 22)) || ((degree > 337 && degree <= 360)); then
        emoji="⬆️" # North
    elif ((degree > 22 && degree <= 67)); then
        emoji="↗️" # North-East
    elif ((degree > 67 && degree <= 112)); then
        emoji="➡️" # East
    elif ((degree > 112 && degree <= 157)); then
        emoji="↘️" # South-East
    elif ((degree > 157 && degree <= 202)); then
        emoji="⬇️" # South
    elif ((degree > 202 && degree <= 247)); then
        emoji="↙️" # South-West
    elif ((degree > 247 && degree <= 292)); then
        emoji="⬅️" # West
    elif ((degree > 292 && degree <= 337)); then
        emoji="↖️" # North-West
    else
        emoji="❓" # Unknown
    fi

    echo "$emoji"
}

formatData() {
    local json="$1"
    local locationInfo="$2"

    # Extract data from JSON

    local lat=$(printf "%.3f" "$(jq -r '.lat' <<<"$locationInfo")")
    local lon=$(printf "%.3f" "$(jq -r '.lon' <<<"$locationInfo")")

    local city=$(jq -r '.name' <<<"$locationInfo")
    local country=$(getCountryName "$(jq -r '.sys.country' <<<"$json")")
    local flag=$(getFlagEmoji "$(jq -r '.sys.country' <<<"$json")")

    local temperature=$(printf "%.1f" "$(jq -r '.main.temp' <<<"$json")")
    local feelsLike=$(printf "%.1f" "$(jq -r '.main.feels_like' <<<"$json")")
    local tempMin=$(printf "%.1f" "$(jq -r '.main.temp_min' <<<"$json")")
    local tempMax=$(printf "%.1f" "$(jq -r '.main.temp_max' <<<"$json")")
    local weatherDescription=$(jq -r '.weather[0].description' <<<"$json")

    local humidity=$(jq -r '.main.humidity' <<<"$json")
    local windSpeed=$(jq -r '.wind.speed' <<<"$json")
    local windDirection=$(getDirectionEmoji "$(jq -r '.wind.deg' <<<"$json")")
    local windGusts=$(jq -r '.wind.gust // 0' <<<"$json")

    local pressure=$(jq -r '.main.pressure' <<<"$json")
    local cloudCover=$(jq -r '.clouds.all' <<<"$json")
    local visibility=$(($(jq -r '.visibility' <<<"$json") / 1000)) # meters to km

    local sunrise=$(jq -r '.sys.sunrise' <<<"$json")
    local sunset=$(jq -r '.sys.sunset' <<<"$json")

    local iconCode=$(jq -r '.weather[0].icon' <<<"$json")
    local icon=$(getWeatherIcon "$iconCode")
    local text="$icon ${temperature}°C"

    local weatherID=$(jq -r '.weather[0].id' <<<"$json")
    local message=$(generateDynamicMessage "$temperature" "$feelsLike" "$weatherID")

    local toolTip="\
    \n\
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
    $message \n\
    "

    echo "{\"text\":\"$text\", \"tooltip\":\"$toolTip\"}"
}

getLocation() {

    # getLocation: Fetches the latitude and longitude for a given city.
    # Arguments:
    #   --city: Name of the city (required)
    #   --state: Name of the state (optional)
    #   --country: Name of the country (optional)
    # Returns:
    #   JSON containing the name, lat, lon, state, and country of the city.

    local city=""
    local state=""
    local country=""

    local args=("$@")
    while [[ ${#args[@]} -gt 0 ]]; do
        case "${args[0]}" in
        --city)
            city="${args[1]}"
            ;;
        --state)
            state="${args[1]}"
            ;;
        --country)
            country="${args[1]}"
            ;;
        *)
            echo "Unknown option \"${args[0]}\"" >&2
            return 1
            ;;
        esac
        args=("${args[@]:2}")
    done

    # Validate required parameters
    if [ -z "$city" ]; then
        echo "Error: The city parameter is required but missing or empty." >&2
        return 1
    fi

    # Build URL based on available parameters
    local url="http://api.openweathermap.org/geo/1.0/direct?q=${city}"
    [[ -n "$state" ]] && url+=",${state}"
    [[ -n "$country" ]] && url+=",${country}"
    url+="&limit=5&appid=${APIKEY}"

    # Fetch and process the response
    local response
    local httpStatusCode
    local responseBody
    local location

    response=$(curl -s -w "%{http_code}" "${url}")
    httpStatusCode="${response: -3}"
    responseBody="${response%???}"

    if [[ $httpStatusCode -ne 200 ]]; then
        echo "Error: Failed to fetch location (HTTP status code $httpStatusCode)" >&2
        return 1
    fi

    location=$(jq '.[0] | { name: .name, lat: .lat, lon: .lon, state: .state, country: .country }' <<<"${responseBody}")
    echo "$location"
}

getDisasterAlert() {
    #!! TODO - Disaster Alert system for cyclones, rain, snow, earthquake etc ...
    pass
}

dailyWeather() {

    # dailyWeather: Fetches daily weather information for a given city.
    # Arguments:
    #   --city: Name of the city (required)
    #   --state: Name of the state (optional)
    #   --country: Name of the country (optional)
    # Returns:
    #   JSON containing various information related to weather forecast for 'today'

    local locationInfo
    local latitude
    local longitude

    locationInfo="$(getLocation "$@")"
    latitude="$(jq '.lat' <<<"${locationInfo}")"
    longitude="$(jq '.lon' <<<"${locationInfo}")"

    local url
    local response

    url="https://api.openweathermap.org/data/2.5/weather?lat={$latitude}&lon={$longitude}&units=metric&appid={$APIKEY}"
    response=$(curl -s "${url}" | jq .)
    formatData "$response" "$locationInfo"
}

weatherForecast() {

    #!!! TODO: Find a free forecast API. Openweather API don't support this in free plan.

    local locationInfo
    local latitude
    local longitude

    locationInfo="$(getLocation "$@")"
    latitude="$(jq '.lat' <<<"${locationInfo}")"
    longitude="$(jq '.lon' <<<"${locationInfo}")"

    local hourlyForecastURL
    local dailyForecastURL
    local response

    # Days in future to get update
    local days=4

    dailyForecastURL="api.openweathermap.org/data/2.5/forecast/daily?lat={$latitude}&lon={$longitude}&cnt={$days}&appid={$APIKEY}"
    hourlyForecastURL="https://pro.openweathermap.org/data/2.5/forecast/hourly?lat={$latitude}&lon={$longitude}&appid={$APIKEY}&lang={en}"
}

main() {
    # Load APIKEY from `.env` file
    if [ -f ../.env ]; then
        export $(cat ../.env | xargs)
    else
        echo "Error: .env file not found or APIKEY not set." >&2
        return 1
    fi

    dailyWeather "$@"
}

main "$@"
