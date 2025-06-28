#!/bin/bash
executionDate=202504011650
duration=1
rampUp=1

# Folder to save the final report after generating
savedReport="/Users/vincent/Work/shb/workspace/perf-test/jmeter/res"
influxToken="GRTrHcIIG5QYoAaV-S7n_NoZB_SPGVStS6SLRicAlbWpBtd4Lfr_h94obOUjAheAxnhp5cPVNvyYgw9ndUQDgg=="
influxOrg="Vincent"
influxBucket="PERF-SAHA"
influxUrl="http://localhost:8086"

# Config default cho savedReport
#if [ -z "$savedReport" ]; then
#    savedReport="/Users/vincent/Work/shb/workspace/perf-test/jmeter/res"
#else
#    savedReport=$1
#fi

#./executionn.sh [JMX File Name] [Testing Type] [EXE DATE] [CCU] [RAMP-UP] [STEPS] [DURATION] [INFLUX TOKEN] [INFLUX ORG] [INFLUX BUCKET] [INFLUX URL]
./executionn.sh 20241220_Testek_ProductMngt Load_Product ${executionDate} 10 4 10 10 ${influxToken} ${influxOrg} ${influxBucket} ${influxUrl}
