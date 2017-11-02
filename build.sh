#!/bin/bash
##################################################################################
clear
echo "${0}: Started - $(date +%Y-%m-%d' '%H:%M:%S)"

JMXEXPORTER_GIT="https://github.com/prometheus/jmx_exporter.git"
JMXEXPORTER_BUILD="build_env"
MVN_CONTAINER=rowanto/docker-java8-mvn-nodejs-npm
MVN_BUILD="mvn package"
GIT=$(which git)

[[ ! -x ${GIT} ]] && echo "${0}: Error - unable to find binary file git. Aborting" && exit 1

[[ -d ${JMXEXPORTER_BUILD} ]] && rm -fr ${JMXEXPORTER_BUILD}
mkdir ${JMXEXPORTER_BUILD} > /dev/null
cd ${JMXEXPORTER_BUILD} 

echo "${0}: Cloning ${JMXEXPORTER_GIT} to ${JMXEXPORTER_BUILD}"
${GIT} clone ${JMXEXPORTER_GIT} > /dev/null 2>&1
[[ $? -ne 0 ]] && echo "${0}: Error - unable to clone git repo ${JMXEXPORTER_GIT}. Aborting" && exit 1

cd - > /dev/null
echo "${0}: Running build with container ${MVN_CONTAINER}"
docker run --rm -v ${PWD}/${JMXEXPORTER_BUILD}/jmx_exporter:/data -w /data ${MVN_CONTAINER} /usr/bin/mvn package > /dev/null
[[ $? -ne 0 ]] && echo "${0}: Error - failed to build jvm_exporter. Aborting" && exit 1

[[ -d bin.old ]] && rm -fr bin.old && echo "${0}: Found old bin folder. Removing"
[[ -d bin ]] && mv bin bin.old && echo "${0}: Fould bin folder. Moving to bin.old"
mkdir bin

JVM_EXPORTER=$(ls ${JMXEXPORTER_BUILD}/jmx_exporter/jmx_prometheus_httpserver/target/*with-de*)
[[ ! -f "${JVM_EXPORTER}" ]] && echo "${0}: Error - unable to find jvm_exporter http server. Aborting" && exit 1
echo "${0}: Found jmx_exporter httpserver jar file ${JVM_EXPORTER}"

JMX_EXPORTER_BASE=$(basename "${JVM_EXPORTER}")

echo "${0}: Moving ${JVM_EXPORTER} to bin foler"
mv ${JVM_EXPORTER} bin
echo "${0}: Creating symbolic link ${JMX_EXPORTER_BASE} -> jmx_prometheus_httpserver.jmx"
cd bin && ln -s ${JMX_EXPORTER_BASE} jmx_prometheus_httpserver.jmx
cd - > /dev/null
rm -fr ${JMXEXPORTER_BUILD}
