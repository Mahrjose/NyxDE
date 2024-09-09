#! /usr/bin/env bash

generateDynamicMessage() {

    # generateDynamicMessage: Generates a dynamic weather message based on temperature and weather conditions.
    # Takes into account the "feels like" temperature and specific weather IDs to create a detailed message.
    # Arguments:
    #   feelsLike : Feels-like temperature in Celsius (required)
    #   weatherID : Weather condition ID, as provided by the OpenWeatherMap API (required)
    # Returns:
    #   A string with a weather advisory message based on temperature and weather conditions.

    local feelsLike="$1"
    local weatherID="$2"
    local message=""

    # Determine message based on "feels like" temperature
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

    # Append additional information based on specific weather IDs
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

    # Format the message to have a maximum number of words per line (for easier reading)
    local maxLength=8 # Num of words per line before wrapping
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

    echo "$message"
}
