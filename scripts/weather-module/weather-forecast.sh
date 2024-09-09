#!/bin/bash

hourlyWeatherForecast() {

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

    #! TODO -> Implement --hourdiff & --dayscount options

    # source ../../.env

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
