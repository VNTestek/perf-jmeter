#!/bin/bash
executionDate=202504011650
duration=5
rampUp=1
# Thu muc luu tru report cuoi cung sau khi generate
#savedReport="/Users/vincent/Work/shb/workspace/perf-test/jmeter/res"
savedReport=$1

#./execution.sh [JMX File Name] [Testing Type] [EXE DATE] [CCU] [RAMP-UP] [STEPS] [DURATION]

./execution.sh 20250328_CompareDB_Postgres SAHA_DBCompare_Postgres ${executionDate} 1 ${rampUp} 1 ${duration}

./deployment/generateReport/generateRawReportScript.sh ${executionDate} ${savedReport}