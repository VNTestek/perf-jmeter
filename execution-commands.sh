#!/bin/bash
# File lệnh tùy chỉnh để thực thi trên tất cả các worker
# Cấu trúc: TIMEOUT=<seconds>; <command>
#
# Tác giả: Testek Education
# Phiên bản: 1.0
# Ngày cập nhật: 2025-04-21

executionDate=202504011650
duration=5
rampUp=1
workerName="VincentTest"

# Kiểm tra và tạo thư mục nếu cần
mkdir -p ${savedReport}

echo "===== Thông tin cấu hình ====="
echo "Execution Date: ${executionDate}"
echo "Duration: ${duration}"
echo "Ramp-up: ${rampUp}"
echo "Worker: ${workerName}"
echo "Result Directory: ${savedReport}"
echo "============================="

#STARTING_EXECUTION

# Test 1: 1 CCU - Với timeout 10 phút (600 giây)
TIMEOUT=60; ./execution.sh 20250328_CompareDB_Postgres SAHA_DBCompare_Postgres ${executionDate} 1 ${rampUp} 1 ${duration} ${workerName}

# Test 2: 100 CCU, 12 steps - Với timeout 30 phút (1800 giây)
TIMEOUT=60; ./execution.sh 20250328_CompareDB_Postgres SAHA_DBCompare_Postgres ${executionDate} 100 ${rampUp} 12 ${duration} ${workerName}

# Test 3: 50 CCU, 10 steps - Với timeout mặc định
TIMEOUT=60; ./execution.sh 20250328_CompareDB_Postgres SAHA_DBCompare_Postgres ${executionDate} 50 ${rampUp} 10 ${duration} ${workerName}

# Test 4: 30 CCU, 15 steps - Với timeout 40 phút (2400 giây)
TIMEOUT=60; ./execution.sh 20250328_CompareDB_Postgres SAHA_DBCompare_Postgres ${executionDate} 30 ${rampUp} 15 ${duration} ${workerName}

echo "Hoàn thành thực thi tất cả các lệnh trên worker ${workerName}"
