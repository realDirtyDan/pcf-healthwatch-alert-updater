
# PCF Healthwatch Alert Updater

A simple shell script to update PCF healthwatch alerts.


## Installation

### Install dependencies cf-uaac and jq.

#### uaac:
https://github.com/cloudfoundry/cf-uaac

#### jq:
https://stedolan.github.io/jq/download


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
  
## Usage

*NOTICE* - do not forget to target UAA and fetch token.

```
Usage: hw-alert-update.sh [OPTION]...

  -d|--dry              show results without making changes to alerts making changes to alerts
  -a|--api      STRING  healthwatch-api.SYSTEM-DOMAIN/v1/alert-configurations
  -c|--critical NUM     critical threshold
  -w|--warning  NUM     warning threshold
  -t|--type     STRING  threeshold type
  -q|--query    REGEX   alert query search string  
  -h|--help|-?          show this help 
```

## Example

*CAUTION* - It's highly recommended that you do a dry run first:

```
$ ./hw-alert-update.sh -a healthwatch-api.run-11.haas-59.pez.pivotal.io/v1/alert-configurations -c 70000 -w 20000 -t UPPER -q 'latency.uaa' --dry
BEFORE:
{
  "query": "origin == 'gorouter' and name == 'latency.uaa'",
  "threshold": {
    "critical": 70000,
    "warning": 10000,
    "type": "UPPER"
  }
}

AFTER:
{
  "query": "origin == 'gorouter' and name == 'latency.uaa'",
  "threshold": {
    "critical": 70000,
    "warning": 20000,
    "type": "UPPER"
  }
}
```

If things look correct run without the `--dry` option to commit the change:

```
$ ./hw-alert-update.sh -a healthwatch-api.run-11.haas-59.pez.pivotal.io/v1/alert-configurations -c 70000 -w 20000 -t UPPER -q 'latency.uaa'
{
  "query" : "origin == 'gorouter' and name == 'latency.uaa'",
  "threshold" : {
    "critical" : 70000.0,
    "type" : "UPPER",
    "warning" : 20000.0
  }
}
```

## Maintainer

* [David Mathis](https://github.com/dbmathis)


## Support

This is a community supported cloud foundry tool. Opening issues for questions, feature requests and/or bugs is the best path to getting "support".


## PCF Documentation

- [Configuring-PCF-Healthwatch-Alerts](https://docs.pivotal.io/pcf-healthwatch/1-2/api/alerts.html):
