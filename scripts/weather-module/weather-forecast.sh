#!/bin/bash

hourlyWeatherForecast() {

    # hourlyWeatherForecast: Fetches and returns the hourly weather forecast for a specific location.
    # It retrieves the forecast for the current day, including temperature, max/min temp, and conditions for each hour.
    # Arguments:
    #   location : The location for which the weather forecast is to be fetched (required).
    # Returns:
    #   A formatted JSON object containing the hourly weather data.

    local location=$1
    local forecast
    local url

    [ -z "$location" ] && echo "Error: No Location provied." >&2 && return 1

    url="https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/${location}/today?unitGroup=metric&include=hours&key=${VISUALCROSSING_APIKEY}&contentType=json"
    response=$(curl -s "${url}")

    forecast=$(jq -r ' .days[0] | {
            date: .datetime,
            temp: .temp,
            temp_max: .tempmax,
            temp_min: .tempmin,
            feelslike: .feelslike,
            description: .description,
            hours: [ .hours[] | {
                time: .datetime,
                temp: .temp,
                desription: .conditions
                }
            ]
        }' <<<"$response")

    echo "$forecast"
}

multiDayWeatherForecast() {

    # multiDayWeatherForecast: Fetches and returns a multi-day weather forecast for a specific location.
    # It retrieves the forecast for the next few days, including daily temperature, max/min temp, and conditions for each day.
    # Arguments:
    #   location : The location for which the weather forecast is to be fetched (required).
    #   days     : The number of days for which the forecast is needed (default is 4 days).
    # Returns:
    #   A formatted JSON object containing the multi-day weather data.

    local location=$1
    local days=4
    local url
    local forecast

    [ -z "$location" ] && echo "Error: No Location provied." >&2 && return 1

    url="https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/${location}/next${days}"days"?unitGroup=metric&include=days&key=${VISUALCROSSING_APIKEY}&contentType=json"
    response=$(curl -s "${url}")

    forecast=$(jq -r '{
            location: .resolvedAddress,
            timezone: .timezone,
            days: [ .days[] | {
                date: .datetime,
                temp: .temp,
                tempmax: .tempmax,
                tempmin: .tempmin,
                feelslike: .feelslike,
                conditions: .conditions,
                desription: .description
                }
            ]
        }' <<<"$response")

    echo "$forecast"

}

getWeatherForecast() {

    # getWeatherForecast: Determines the type of weather forecast (hourly or multi-day) based on the argument provided.
    # Arguments:
    #   --hourly    : Fetches the hourly weather forecast for a given location.
    #   --multidays : Fetches the multi-day weather forecast for a given location.
    # Returns:
    #   None

    #! TODO -> Implement --hourdiff & --dayscount options

    case "$1" in
    --hourly)
        shift 1
        hourlyWeatherForecast "$@"
        ;;
    --multidays)
        shift 1
        multiDayWeatherForecast "$@"
        ;;
    *)
        echo "Error: Argument missing. Please specifiy --hourly or --daily" >&2
        return 1
        ;;
    esac
}
