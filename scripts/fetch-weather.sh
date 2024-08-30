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
    pass
}

formatData() {
    local json="$1"

    # Extract data from JSON
    local location=$(jq -r '.name + ", " + .sys.country' <<<"$json")
    local temperature=$(printf "%.1f" "$(jq -r '.main.temp' <<<"$json")")
    local feelsLike=$(printf "%.1f" "$(jq -r '.main.feels_like' <<<"$json")")
    local tempMin=$(printf "%.1f" "$(jq -r '.main.temp_min' <<<"$json")")
    local tempMax=$(printf "%.1f" "$(jq -r '.main.temp_max' <<<"$json")")
    local weatherDescription=$(jq -r '.weather[0].description' <<<"$json")

    local humidity=$(jq -r '.main.humidity' <<<"$json")
    local windSpeed=$(jq -r '.wind.speed' <<<"$json")
    local windDeg=$(jq -r '.wind.deg' <<<"$json")
    local windGusts=$(jq -r '.wind.gust // 0' <<<"$json")

    local pressure=$(jq -r '.main.pressure' <<<"$json")
    local cloudCover=$(jq -r '.clouds.all' <<<"$json")
    local visibility=$(($(jq -r '.visibility' <<<"$json") / 1000)) # meters to km

    local sunrise=$(jq -r '.sys.sunrise' <<<"$json")
    local sunset=$(jq -r '.sys.sunset' <<<"$json")

    local iconCode=$(jq -r '.weather[0].icon' <<<"$json")
    local icon=$(getWeatherIcon "$iconCode")
    local text="$icon ${temperature}°C"

    # -------------------------------Text Format-------------------------------

    local toolTip="\
\n\
📍 Location: $location\n\
\n\
🌡️ Current Weather: ${temperature}°C | ${weatherDescription^}\n\
    🔥 Feels Like: ${feelsLike}°C\n\
    🔼 High: ${tempMax}°C, 🔽 Low: ${tempMin}°C\n\
\n\
📊 Additional Details:          \n\
    💧 Humidity: ${humidity}%   \n\
    🌬️ Wind: ${windSpeed} km/h (From ${windDeg}°)   \n\
    🌪️ Wind Gusts: ${windGusts} km/h    \n\
    👀 Visibility: ${visibility} km     \n\
    ☁️ Cloud Cover: ${cloudCover}%      \n\
    📊 Pressure: ${pressure} hPa        \n\
\n\
🌅 Sunrise: $(date -d @$sunrise +'%I:%M %p') 🌄 | Sunset: $(date -d @$sunset +'%I:%M %p') 🌃    \n\
\n\
📈 Note: It might rain tomorrow, carry an umbrella! ☂️  \n\
"
    # -------------------------------------------------------------------------

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
    formatData "$response"
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
    # echo "{\"text\":\"☀️ 28°C\", \"tooltip\":\"Sunny with clear skies\"}"

}

main "$@"
