#!/usr/bin/env bash

formatData() {
    local json="$1"

    local location=$(jq -r '.name + ", " + .sys.country' <<<"$json")
    local temperature=$(jq -r '.main.temp' <<<"$json")
    local feelsLike=$(jq -r '.main.feels_like' <<<"$json")
    local tempMin=$(jq -r '.main.temp_min' <<<"$json")
    local tempMax=$(jq -r '.main.temp_max' <<<"$json")
    local weatherDescription=$(jq -r '.weather[0].description' <<<"$json")
    local humidity=$(jq -r '.main.humidity' <<<"$json")
    local windSpeed=$(jq -r '.wind.speed' <<<"$json")
    local windDeg=$(jq -r '.wind.deg' <<<"$json")
    local windGusts=$(jq -r '.wind.gust // 0' <<<"$json")
    local pressure=$(jq -r '.main.pressure' <<<"$json")
    local seaLevelPressure=$(jq -r '.main.sea_level // 0' <<<"$json")
    local groundLevelPressure=$(jq -r '.main.grnd_level // 0' <<<"$json")
    local cloudCover=$(jq -r '.clouds.all' <<<"$json")
    local visibility=$(jq -r '.visibility' <<<"$json")
    local sunrise=$(jq -r '.sys.sunrise' <<<"$json")
    local sunset=$(jq -r '.sys.sunset' <<<"$json")

    # Convert visibility from meters to kilometers
    local visibility_km=$((visibility / 1000))

    echo "📍 Location: $location"
    echo "   (City in the northeastern ${location##*,})"
    echo ""
    echo "🌡️ Current Weather: ${temperature}°C | ${weatherDescription}"
    echo "   🔥 Feels Like: ${feelsLike}°C"
    echo "   🔼 High: ${tempMax}°C, 🔽 Low: ${tempMin}°C"
    echo ""
    echo "📊 Additional Details:"
    echo "   💧 Humidity: ${humidity}%"
    echo "   🌬️ Wind: ${windSpeed} km/h (From ${windDeg}°)"
    echo "   🌪️ Wind Gusts: ${windGusts} km/h"
    echo "   👀 Visibility: ${visibility_km} km"
    echo "   ☁️ Cloud Cover: ${cloudCover}%"
    echo "   📊 Pressure: ${pressure} hPa"
    [[ $seaLevelPressure -gt 0 ]] && echo "   🌊 Sea Level Pressure: ${seaLevelPressure} hPa"
    [[ $groundLevelPressure -gt 0 ]] && echo "   🏔️ Ground Level Pressure: ${groundLevelPressure} hPa"
    echo ""
    echo "🌅 Sunrise: $(date -d @$sunrise +'%I:%M %p') 🌄 | Sunset: $(date -d @$sunset +'%I:%M %p') 🌃"
    echo ""
    echo "📈 Note: It might rain tomorrow, carry an umbrella! ☂️"
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
    # weatherForecast "$@"

}

main "$@"
