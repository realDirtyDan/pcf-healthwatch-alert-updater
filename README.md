
# PCF Healthwatch Alert Updater

A simple shell script to update PCF healthwatch alerts.


## Installation

### Install dependencies jq and cf-uaac
```
$ gem install cf-uaac
$ install jq: [instructions here](https://stedolan.github.io/jq/download/)
```

### Install updater
```
$ git clone https://github.com/dbmathis/pcf-healthwatch-alert-updater.git
$ cd pcf-healthwatch-alert-updater
$ chmod +x hw-alert-updater.sh
```

## Target CF UAA and fetch a client token for healthwatch api admin.
```
$ uaac target <cf-uaa> [--skip-ssl-validation]
$ uaac token client get healthwatch_api_admin -s <secret>
```
  
## Commands
```
$ ./hw-alert-updater.sh --api <healthwatch-api> --type <type> --critical <num> --warning <num> --query <regex>
```

## Links associated this application.

- [Configuring-PCF-Healthwatch-Alerts](https://docs.pivotal.io/pcf-healthwatch/1-2/api/alerts.html):
