
# PCF Healthwatch Alert Updater

A simple shell script to update PCF healthwatch alerts.


## Install jq and cf-uaac
```
$ gem install cf-uaac
$ brew install jq
```

## Clone repositiory
```
$ git clone <repo>


## Target cf UAA and fetch a client token for haelthwatch api admin.
```
$ uaac target <cf-uaa> [--skip-ssl-validation]
$ uaac token client get healthwatch_api_admin -s <secret>
```
  
## Commands
```
$ chmod +x hw-alert-updater.sh
$ ./hw-alert-updater.sh options
```

## Links associated this application.

- [Configuring-PCF-Healthwatch-Alerts](https://docs.pivotal.io/pcf-healthwatch/1-2/api/alerts.html):
