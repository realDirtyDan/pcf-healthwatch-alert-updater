#!/bin/sh
# POSIX

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

# Initialize all the option variables.
# This ensures we are not contaminated by variables from the environment.
api=
critical=0
verbose=0

while :; do
    case $1 in
        -h|-\?|--help)
            echo 'No help'    # Display a usage synopsis.
            exit
            ;;
        -a|--api)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                api=$2
                shift
            else
                die 'ERROR: "--api" requires a non-empty option argument.'
            fi
            ;;
        --api=?*)
            api=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --api=)         # Handle the case of an empty --api=
            die 'ERROR: "--api" requires a non-empty option argument.'
            ;;
        -c|--critical)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                critical=$2
                shift
            else
                die 'ERROR: "--api" requires a non-empty option argument.'
            fi
            ;;
        --critical=?*)
            critical=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --critical=)         # Handle the case of an empty --critical=
            die 'ERROR: "--critical" requires a non-empty option argument.'
            ;;
        -v|--verbose)
            verbose=$((verbose + 1))  # Each -v adds 1 to verbosity.
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: No more options, so break out of the loop.
            break
    esac

    shift
done

# if --api was provided
if [ "$api" ] && [ "$critical" ]; then
    export token=$(uaac context | grep access_token | awk '{print $2}')
    curl -sG "$api" -H "Authorization: Bearer ${token}" | jq ".[] | select(.query|test(\"latency.uaa\")) | .threshold.critical = ${critical} | .threshold.type = \"UPPER\" | .threshold.warning = 20000" | curl -d @- -H "Authorization: Bearer ${token}" -H "Accept: application/json" -H "Content-Type: application/json" "$api"
fi
