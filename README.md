# jmxexporter

## Parameterized docker startup
This docker container contains the [jmx_exporter](https://github.com/prometheus/jmx_exporter) http server jar. 
An entrypoint.sh file was added in order to make it configurable. 

## Parameters
```bash
JMX_HOME=${JMX_HOME:-/data}
JMX_HOST=${JMX_HOST:-$HOSTNAME}
JMX_PORT=${JMX_PORT:-5555}
JMX_PATTERN=${JMX_PATTERN:=.*}

JMX_CONF=${JMX_CONF:-httpserver_config.yml}

JMX_DEBUG=${JMX_DEBUG_LOCAL:-0}
JMX_DEBUG_PORT=${JMX_DEBUG_PORT:-7777}

JMX_USERNAME=${JMX_USERNAME:-}
JMX_PASSWORD=${JMX_PASSWORD:-}

HTTP_PORT=${HTTP_PORT:-5556}
```
