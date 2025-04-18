#!/bin/bash

# Kiểm tra nếu không có đủ tham số được truyền vào
if [ "$#" -lt 5 ]; then
  echo "Sử dụng: $0 <Test Scenario Name [Type]_[Product], Ex: Load_SAHA> <DateRes> <CCU> <Rampup> <Step> <Duration>"
  echo "Example: ./execution.sh 20241016_Transfer_Napas SAHA_Napas_Load 20241224 1 1 1 1"
  exit 1
fi

jmx=$1
scenario=$2
resFol=$3
ccu=$4
ramp=$5
steps=$6
duration=$7

# for influxDB: 192.168.90.34
influxToken=GRTrHcIIG5QYoAaV-S7n_NoZB_SPGVStS6SLRicAlbWpBtd4Lfr_h94obOUjAheAxnhp5cPVNvyYgw9ndUQDgg==
influxOrg=Vincent
influxBucket=PERF-SAHA

currentDate=$(date +'%Y%m%d_%H%M%S')
resPath=${currentDate}_${scenario}_${ccu}C${ramp}R${steps}S${duration}D
reportPath="res/${resFol}/${resPath}"
echo "=================================================================================="
echo " Test Scenario:  ${scenario}    Execution Time:  ${currentDate}"
echo " Test Info: CCU:  ${ccu}  Ramp-up:  ${ramp}m   Step: ${steps}  Duration:  ${duration}m"
echo " Report Path: ${reportPath}"
echo "=================================================================================="

mkdir -p ${reportPath}
sleep 5

echo "./bin/jmeter  -Jjmeter.save.saveservice.output_format=csv -Jjmeter.save.saveservice.response_data=true -Jjmeter.save.saveservice.samplerData=true -Jjmeter.save.saveservice.requestHeaders=true -Jjmeter.save.saveservice.responseHeaders=true -Jjmeter.save.saveservice.url=true -n -t jmx/${jmx}.jmx -l ${reportPath}/${resPath}.jtl -DRPath=${reportPath}/${resPath}.xml -DUSERS=${ccu} -DRAMP=${ramp} -DSTEP=${steps} -DDURA=${duration}"
./bin/jmeter  -Jjmeter.save.saveservice.output_format=csv -Jjmeter.save.saveservice.response_data=true -Jjmeter.save.saveservice.samplerData=true -Jjmeter.save.saveservice.requestHeaders=true -Jjmeter.save.saveservice.responseHeaders=true -Jjmeter.save.saveservice.url=true -n -t jmx/${jmx}.jmx -l ${reportPath}/${resPath}.jtl -DRPath=${reportPath}/${resPath}.xml -DUSERS=${ccu} -DRAMP=${ramp} -DSTEP=${steps} -DDURA=${duration}  -DORG=${influxOrg} -DBUCKET=${influxBucket} -DTOKEN=${influxToken}

#./bin/jmeter  -Jjmeter.save.saveservice.output_format=csv -Jjmeter.save.saveservice.response_data=true -Jjmeter.save.saveservice.samplerData=true -Jjmeter.save.saveservice.requestHeaders=true -Jjmeter.save.saveservice.responseHeaders=true -Jjmeter.save.saveservice.url=true -n -t jmx/20241021_ESB_Card.jmx -l res/${resPath}/result.jtl -DUSERS=${ccu} -DRAMP=${ramp} -DSTEP=${steps} -DDURA=${duration} -DORG=Automation_Test -DBUCKET=SAHA -DRUNID=POD1_1024_ESB
#-e -o res/${resPath}
sleep 10

echo "===== Generate HTML Report ====="
./bin/jmeter -g res/${resFol}/${resPath}/${resPath}.jtl -o res/${resFol}/${resPath}/html
echo "=====================END OF TESTING ==============================================="
sleep 30

sleep 180

#./bin/jmeter -Jjmeter.save.saveservice.output_format=xml -Jjmeter.save.saveservice.response_data=true -Jjmeter.save.saveservice.samplerData=true -Jjmeter.save.saveservice.requestHeaders=true -J jmeter.save.saveservice.responseHeaders=true -Jjmeter.save.saveservice.url=true -n -t jmx/20241021_ESB_Transfer.jmx -l res/${resPath}/result.jtl  -e -o res/${resPath} -DUSERS=${ccu} -DRAMP=${ramp} -DSTEP=${steps} -DDURA=${duration} -DORG=Automation_Test -DBUCKET=SAHA -DRUNID=POD1_1024_ESB