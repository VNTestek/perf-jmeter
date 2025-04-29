#!/bin/bash
# Script to execute JMeter tests with specific parameters
# Cấu trúc: TIMEOUT=<seconds>; <command>
# Class dùng cho việc thực thi muliple test cases -> PENDING, sử dụng test_scenarios.txt

# Author: Testek Education
# Version: 1.0
# Update: 2025-04-21
# Configuration:
# executionDate=202504011650
# duration=5
# rampUp=1
# workerName="VincentTest"

# Create a directory to save the report
# mkdir -p ${savedReport}
# TIMEOUT=60; ./execution.sh [JMX File Name] [Testing Type _ Function Type] ${executionDate} USERS RAMP STEP DURATION ${workerName}
# Exam: ./execution.sh 20250328_CompareDB_Postgres SAHA_DBCompare_Postgres ${executionDate} 1 1 1 1 ${workerName}
TIMEOUT=600; ./execution.sh 20250418_Execution_Script_Demo Testek_Demo {ExecutionDate} 1 1 1 1 {WorkerName}
TIMEOUT=600; ./execution.sh 20250418_Execution_Script_Demo Testek_Demo {ExecutionDate} 10 1 1 1 {WorkerName}
TIMEOUT=600; ./execution.sh 20250418_Execution_Script_Demo Testek_Demo {ExecutionDate} 100 1 1 1 {WorkerName}