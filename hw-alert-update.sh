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
warning=0
type=0
query=
verbose=0

function usage {
	cat <<EOM
Usage: $(basename "$0") [OPTION]...

  -a|--api      STRING  healthwatch-api.SYSTEM-DOMAIN/v1/alert-configurations
  -c|--critical NUM     critical threshold
  -w|--warning  NUM     warning threshold
  -t|--type     STRING  threeshold type
  -q|--query    REGEX   alert query search string  
  -h|--help             show this help            
EOM
    exit 2
}

while :; do
    case $1 in
        -h|-\?|--help)
            usage  # Display a usage synopsis.
            exit
            ;;
        -a|--api)           # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                api=$2
                shift
            else
                die 'ERROR: "--api" requires a non-empty option argument.'
            fi
            ;;
        --api=?*)
            api=${1#*=}     # Delete everything up to "=" and assign the remainder.
            ;;
        --api=)             # Handle the case of an empty --api=
            die 'ERROR: "--api" requires a non-empty option argument.'
            ;;
        -c|--critical)      # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                critical=$2
                shift
            else
                die 'ERROR: "--critical" requires a non-empty option argument.'
            fi
            ;;
        --critical=?*)
            critical=${1#*=}# Delete everything up to "=" and assign the remainder.
            ;;
        --critical=)        # Handle the case of an empty --critical=
            die 'ERROR: "--critical" requires a non-empty option argument.'
            ;;
        -w|--warning)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                warning=$2
                shift
            else
                die 'ERROR: "--warning" requires a non-empty option argument.'
            fi
            ;;
        --warning=?*)
            warning=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --warning=)         # Handle the case of an empty --warning=
            die 'ERROR: "--warning" requires a non-empty option argument.'
            ;;
        -t|--type)          # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                type=$2
                shift
            else
                die 'ERROR: "--type" requires a non-empty option argument.'
            fi
            ;;
        --type=?*)
            type=${1#*=}    # Delete everything up to "=" and assign the remainder.
            ;;
        --type=)            # Handle the case of an empty --type=
            die 'ERROR: "--type" requires a non-empty option argument.'
            ;;
        -q|--query)         # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                query=$2
                shift
            else
                die 'ERROR: "--query" requires a non-empty option argument.'
            fi 
            ;;
        --query=?*)
            query=${1#*=}   # Delete everything up to "=" and assign the remainder.
            ;;
        --query=)           # Handle the case of an empty --query=
            die 'ERROR: "--query" requires a non-empty option argument.'
            ;;
        -v|--verbose)
            verbose=$((verbose + 1))  # Each -v adds 1 to verbosity.
            ;;
        --)                 # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)                  # Default case: No more options, so break out of the loop.
            break
    esac

    shift
done

# if --api was provided
if [ "$api" ] && [ "$critical" ] && [ "$warning" ] && [ "$type" ] && [ "$query" ]; then
    export token=$(uaac context | grep access_token | awk '{print $2}')
    curl -sG "$api" -H "Authorization: Bearer ${token}" | 
    jq ".[] | select(.query|test(\"$query\")) | .threshold.critical = ${critical} | .threshold.type = \"${type}\" | .threshold.warning = ${warning}" | 
    curl -d @- -H "Authorization: Bearer ${token}" -H "Accept: application/json" -H "Content-Type: application/json" "$api"
fi
