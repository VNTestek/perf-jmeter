#!/bin/bash
executionDate=202504011650
duration=5
rampUp=1

# Folder to save the final report after generating
savedReport=$1
influxToken=$2
influxOrg=$3
influxBucket=$4

# Config default cho savedReport
if [ -z "$savedReport" ]; then
    savedReport="/Users/vincent/Work/shb/workspace/perf-test/jmeter/res"
else
    savedReport=$1
fi

# Config cho InfluxDB
if [ -z "$influxToken" ]; then
    influxToken="GRTrHcIIG5QYoAaV-S7n_NoZB_SPGVStS6SLRicAlbWpBtd4Lfr_h94obOUjAheAxnhp5cPVNvyYgw9ndUQDgg=="
else
    influxToken=$2
fi
if [ -z "$influxOrg" ]; then
    influxOrg="Vincent"
else
    influxOrg=$3
fi

if [ -z "$influxBucket" ]; then
    influxBucket="PERF-SAHA"
else
    influxBucket=$4
fi


#./execution.sh [JMX File Name] [Testing Type] [EXE DATE] [CCU] [RAMP-UP] [STEPS] [DURATION]
./execution.sh 20250328_CompareDB_Postgres SAHA_DBCompare_Postgres ${executionDate} 1 ${rampUp} 1 ${duration} ${influxToken} ${influxOrg} ${influxBucket}
