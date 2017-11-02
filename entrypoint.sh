#!/usr/bin/env bash

###########################################################################################################
# Set default runtime variables
###########################################################################################################

JMX_HOME=${JMX_HOME:-/data}
JMX_HOST=${JMX_HOST:-$HOSTNAME}
JMX_PORT=${JMX_PORT:-5555}
JMX_PATTERN=${JMX_PATTERN:=.*}

JMX_CONF=${JMX_CONF:-httpserver_config.yml}

###########################################################################################################
# Set debug options for local JMX 
###########################################################################################################
JMX_DEBUG=${JMX_DEBUG_LOCAL:-0}
JMX_DEBUG_PORT=${JMX_DEBUG_PORT:-7777}

###########################################################################################################
# Set JMX username / password. Default empty
###########################################################################################################
JMX_USERNAME=${JMX_USERNAME:-}
JMX_PASSWORD=${JMX_PASSWORD:-}

###########################################################################################################
# Construct host.domain. Used for Statefulsets with Kubebernetes.
###########################################################################################################
if [ "${JMX_DOMAIN}" != "" ]; then
	JMX_HOST=${JMX_HOST}.${JMX_DOMAIN}
fi

###########################################################################################################
# Container HTTP port to listen on. Dont forget to open the specific port (docker -p)
###########################################################################################################
HTTP_PORT=${HTTP_PORT:-5556}

###########################################################################################################
# Local configuration options
###########################################################################################################
CONFIG_DIR="config"
CONFIG_FILE="${CONFIG_DIR}/${JMX_CONF}"
CONFIG_RUN=/tmp/jmx.yaml

JMX_BIN=bin/jmx_prometheus_httpserver.jmx
JAVA_BIN=$(which java)

if [ ! -d ${JMX_HOME} ]; then
	echo "Error:${0}| unable to locatie local working directory ${JMX_HOME}"
	exit 1
fi

cd ${JMX_HOME}

if [ ! -x ${JAVA_BIN} ]; then
	echo "Error:${0}| java binary not found. Aborting."
	exit 1
fi

if [ ! -f ${CONFIG_FILE} ]; then
	echo "Error:${0}| unable to locate configuration file ${CONFIG_FILE}"
	exit 1
fi

if [ ${HTTP_PORT} -lt 1024 ]; then
	echo "Error:${0}| using privileged port which is not supported by current user"
	exit 1
fi

sed -e "s@JMX_HOST@${JMX_HOST}@g" \
    -e "s@JMX_PORT@${JMX_PORT}@g" \
    -e "s@JMX_USERNAME@${JMX_USERNAME}@g" \
    -e "s@JMX_PASSWORD@${JMX_PASSWORD}@g" \
    -e "s@JMX_PATTERN@${JMX_PATTERN}@g" \
    ${CONFIG_FILE} > ${CONFIG_RUN}

if [ "${JMX_DEBUG}" == "0" ]; then
	${JAVA_BIN} -jar ${JMX_BIN} ${HTTP_PORT} ${CONFIG_RUN}
else
	${JAVA_BIN} -Dcom.sun.management.jmxremote.ssl=false \
		    -Dcom.sun.management.jmxremote.authenticate=false \
		    -Dcom.sun.management.jmxremote.port=${JMX_DEBUG_PORT} \
		    -jar ${JMX_BIN} ${HTTP_PORT} ${CONFIG_RUN}
fi
