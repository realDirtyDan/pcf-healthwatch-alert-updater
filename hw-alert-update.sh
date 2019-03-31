#!/bin/sh
# PCF Healthwatch Alert Updater - A tool to easily update healthwatch alerts.
# dmathis@pivotal.io
# POSIX

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

# Initialize all the option variables.
# This ensures we are not contaminated by variables from the environment.
config=
dry=
api=
critical=0
warning=0
type=0
query=
verbose=0

typecheck=false
warningcheck=false
criticalcheck=false

# Define usage
function usage {
    cat <<EOM
Usage: $(basename "$0") [OPTION]...

  --get-config          show current alert configuration
  -d|--dry              show results without making changes to alerts
  -a|--api      STRING  healthwatch-api.SYSTEM-DOMAIN/v1/alert-configurations
  -c|--critical NUM     critical threshold
  -w|--warning  NUM     warning threshold
  -t|--type     STRING  threeshold type
  -q|--query    REGEX   alert query search string  
  -h|--help             show this help            

Examples:

  $ ./hw-alert-update.sh -a healthwatch-api.SYSTEM-DOMAIN/v1/alert-configurations --get-config
  $ ./hw-alert-update.sh -a healthwatch-api.SYSTEM-DOMAIN/v1/alert-configurations -t UPPER -w 100 -c 200 -q 'latency.uaa' --dry
  $ ./hw-alert-update.sh -a healthwatch-api.SYSTEM-DOMAIN/v1/alert-configurations -t UPPER -w 100 -c 200 -q 'latency.uaa'
EOM
    exit 2
}

# Process options
while :; do
    case $1 in
        -h|-\?|--help)
            usage           # Display a usage synopsis.
            exit
            ;;
        --get-config)
            config=true     # config option true
            ;;
        -d|--dry)
            dry=true        # dry run option true
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
                criticalcheck=true
                shift
            fi
            ;;
        --critical=?*)
            critical=${1#*=}# Delete everything up to "=" and assign the remainder.
            criticalcheck=true
            ;;
        -w|--warning)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                warning=$2
                warningcheck=true
                shift
            fi
            ;;
        --warning=?*)
            warning=${1#*=} # Delete everything up to "=" and assign the remainder.
            warningcheck=true
            ;;
        -t|--type)          # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                type=$2
                typecheck=true
                shift
            fi
            ;;
        --type=?*)
            type=${1#*=}    # Delete everything up to "=" and assign the remainder.
            typecheck=true
            ;;
        -q|--query)         # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                query=$2
                shift
            fi 
            ;;
        --query=?*)
            query=${1#*=}   # Delete everything up to "=" and assign the remainder.
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

# Set token env
export token=$(uaac context | grep access_token | awk '{print $2}')

function join { local IFS="$1"; shift; echo "$*"; }

# Setup jq
select=".[] | select(.query|test(\"${query}\")) |"
    
thresholds=()

if [ "$criticalcheck" == true ]; then
    thresholds+=(".threshold.critical=${critical}")
fi
if [ "$typecheck" == true ]; then
    thresholds+=(".threshold.type=\"${type}\"") 
fi 
if [ "$warningcheck" == true ]; then
    thresholds+=(".threshold.warning=${warning}") 
fi
update=$(join '|' ${thresholds[@]})

# Display alert configurations
if [ "$config" == true ] && [ "$api" ]; then
    curl -sG "$api" -H "Authorization: Bearer ${token}" | jq
# Perform a dry run
elif [ "$dry" == true ] && [ "$api" ]; then
    # Output entities that are targeted for update
    echo 'BEFORE:'
    curl -sG "$api" -H "Authorization: Bearer ${token}" | 
    jq ".[] | select(.query|test(\"${query}\"))"
    echo ''
    # Output entities after update
    echo 'AFTER:'
    curl -sG "$api" -H "Authorization: Bearer ${token}" | jq "${select} ${update}"   
elif [ "$api" ]; then
    # Update entities
    curl -sG "$api" -H "Authorization: Bearer ${token}" | jq "${select} ${update}" |
    curl -d @- -H "Authorization: Bearer ${token}" -H "Accept: application/json" -H "Content-Type: application/json" "$api"
else
    usage
fi
