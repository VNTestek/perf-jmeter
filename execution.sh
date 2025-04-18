#!/bin/bash

# Kiểm tra nếu không có đủ tham số được truyền vào
if [ "$#" -lt 5 ]; then
  echo "Sử dụng: $0 <Test Scenario Name [Type]_[Product], Ex: Load_SAHA> <CCU> <Rampup> <Step> <Duration>"
  exit 1
fi

jmx=$1
scenario=$2
ccu=$3
ramp=$4
steps=$5
duration=$6


currentDate=$(date +'%Y%m%d_%H%M%S')
resPath=${currentDate}_${scenario}_${ccu}C${ramp}R${steps}S${duration}D
echo "=================================================================================="
echo " Test Scenario:  ${scenario}    Execution Time:  ${currentDate}"
echo " Test Info: CCU:  ${ccu}  Ramp-up:  ${ramp}m   Step: ${steps}  Duration:  ${duration}m"
echo "=================================================================================="

mkdir -p res/${resPath}
sleep 5
./bin/jmeter  -Jjmeter.save.saveservice.output_format=csv -Jjmeter.save.saveservice.response_data=true -Jjmeter.save.saveservice.samplerData=true -Jjmeter.save.saveservice.requestHeaders=true -Jjmeter.save.saveservice.responseHeaders=true -Jjmeter.save.saveservice.url=true -n -t jmx/${jmx}.jmx -l res/${resPath}/result.jtl -DUSERS=${ccu} -DRAMP=${ramp} -DSTEP=${steps} -DDURA=${duration} -DORG=AutomationTest -DBUCKET=SAHA15 -DRUNID=AWS
#./bin/jmeter  -Jjmeter.save.saveservice.output_format=csv -Jjmeter.save.saveservice.response_data=true -Jjmeter.save.saveservice.samplerData=true -Jjmeter.save.saveservice.requestHeaders=true -Jjmeter.save.saveservice.responseHeaders=true -Jjmeter.save.saveservice.url=true -n -t jmx/20241021_ESB_Card.jmx -l res/${resPath}/result.jtl -DUSERS=${ccu} -DRAMP=${ramp} -DSTEP=${steps} -DDURA=${duration} -DORG=Automation_Test -DBUCKET=SAHA -DRUNID=POD1_1024_ESB
#-e -o res/${resPath}
sleep 10


./bin/jmeter -g res/${resPath}/result.jtl -o res/${resPath}/html
echo "=====================END OF TESTING ==============================================="
sleep 30


#./bin/jmeter -Jjmeter.save.saveservice.output_format=xml -Jjmeter.save.saveservice.response_data=true -Jjmeter.save.saveservice.samplerData=true -Jjmeter.save.saveservice.requestHeaders=true -J jmeter.save.saveservice.responseHeaders=true -Jjmeter.save.saveservice.url=true -n -t jmx/20241021_ESB_Transfer.jmx -l res/${resPath}/result.jtl  -e -o res/${resPath} -DUSERS=${ccu} -DRAMP=${ramp} -DSTEP=${steps} -DDURA=${duration} -DORG=Automation_Test -DBUCKET=SAHA -DRUNID=POD1_1024_ESB