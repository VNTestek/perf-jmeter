#!/bin/bash

# Script thực thi đồng bộ các lệnh trên nhiều worker với timeout
# Sử dụng: ./sync-worker-execution.sh <commands_file> <result_dir> [default_timeout]

COMMANDS_EXE=$1                 # Command cần thực thi
RESULT_DIR=$2                   # Thư mục lưu trữ kết quả
DEFAULT_TIMEOUT=${3:-1200}      # Thời gian chờ mặc định (giây); 1200 giây = 20 phút
WORKER_NAME_EXE=$4              # Tên worker thực thi lệnh
TIMESTAMP=$5                    # Thời gian thực thi tập lệnh (YYYYMMDD_HHMM)
API_SERVER=$6                   # Địa chỉ API server
MAX_WAIT_TIME=${7:-300}         # Thời gian chờ tối đa cho tất cả các worker (giây)
AUTH_KEY=$8                     # Khóa xác thực cho API server

echo "Đang thực thi lệnh: $COMMANDS_EXE"
# Thiết lập logging
LOG_DIR="${RESULT_DIR}/logs"
mkdir -p $LOG_DIR
LOG_FILE="${LOG_DIR}/sync_execution_${WORKER_NAME_EXE}.log"
WORKER_NAME="${TIMESTAMP}_${WORKER_NAME_EXE}"

# Hàm logging
log() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    case $level in
    "INFO") echo -e "[INFO][$timestamp] \t- $message" ;;
    "WARN") echo -e "[WARN][$timestamp] \t- $message" ;;
    "ERROR") echo -e "[ERROR][$timestamp] \t- $message" ;;
    "DEBUG") echo -e "[DEBUG][$timestamp] \t- $message" ;;
    *) echo -e "$timestamp - $message" ;;
    esac
    echo "[$level] $timestamp - $message" >>$LOG_FILE
}

# Hàm gọi API với retry
call_api() {
    local method=$1
    local endpoint=$2
    local data=$3
    local max_retries=3
    local retry=0
    local status_code
    local response

    while [ $retry -lt $max_retries ]; do
        if [ "$method" = "GET" ]; then
            echo "\nGET request to ${API_SERVER}${endpoint}"
            response=$(curl -s -w "%{http_code}" -X GET "${API_SERVER}${endpoint}")
        elif [ "$method" = "POST" ]; then
            echo "\nPOST request to ${API_SERVER}${endpoint} with data: $data"
            response=$(curl -s -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "$data" "${API_SERVER}${endpoint}")
        elif [ "$method" = "DELETE" ]; then
            echo "\nDELETE request to ${API_SERVER}${endpoint}"
            response=$(curl -s -w "%{http_code}" -X DELETE "${API_SERVER}${endpoint}")
        fi

        status_code=${response: -3}
        body=${response:0:${#response}-3}

        if [ "$status_code" = "200" ]; then
            echo "$body"
            return 0
        else
            log "WARN" "API call failed: $status_code - $body, retrying ($retry/$max_retries)..."
            retry=$((retry + 1))
            sleep 1
        fi
    done

    log "ERROR" "API call failed after $max_retries retries"
    return 1
}

# Update the worker status
update_worker_status() {
    local executionId=$1
    local status=$2
    local data="{\"workerId\":\"${WORKER_NAME}\",\"executionId\":\"${executionId}\",\"status\":\"${status}\"}"
    local apiPath="/api/workerStatus?auth=${AUTH_KEY}"

    log "INFO" "🔄 Đánh dấu worker $WORKER_NAME sẵn sàng cho lệnh: $command_id"
    local response=$(call_api "POST" $apiPath "$data")
    if [ $? -ne 0 ]; then
        log "ERROR" "❌ Không thể cập nhật status of worker: $response"
    else
        log "DEBUG" "✅ Đã cập nhật trạng thái worker: $response"
    fi
}

# Clean up all status before execution
cleanup_worker_status() {
    local isAll=$1
    log "INFO" "🧹 Dọn dẹp trạng thái worker trước khi thực thi lệnh"

    local apiPath="/api/cleanup?auth=${AUTH_KEY}&isAll=${isAll}"
    local response=$(call_api "DELETE" $apiPath)
    if [ $? -ne 0 ]; then
        log "ERROR" "❌ Không thể dọn dẹp trạng thái worker: $response"
    else
        log "DEBUG" "✅ Đã dọn dẹp trạng thái worker: $response"
    fi
}

# Get status of all workers
get_all_worker_status() {
    local expStatus=$1
    local index=$2
    log "INFO" "🔍 Kiểm tra trạng thái của tất cả worker"

    local apiPath="/api/allWorkersStatus?auth=${AUTH_KEY}&status=${expStatus}&index=${index}"
    local response=$(call_api "GET" $apiPath)
    if [ $? -ne 0 ]; then
        log "ERROR" "❌ Không thể lấy trạng thái của tất cả worker: $response"
    else
        log "DEBUG" "✅ Trạng thái của tất cả worker: $response"
    fi
}

# Get status of all workers
update_command_list() {
    local commandList=$1
    log "INFO" "🔍 Cập nhật thông tin danh sách command"

    local apiPath="/api/saveAllCommand?auth=${AUTH_KEY}"
    local data="{\"commands\":\"${commandList}\"}"

    local response=$(call_api "POST" $apiPath "$data")
    if [ $? -ne 0 ]; then
        log "ERROR" "❌ Không thể lưu danh sách command thực thi: $response"
    else
        log "DEBUG" "✅ Đã lưu danh sách command thực thi: $response"
    fi
}


#Get status of specific worker
get_command_list() {
    log "INFO" "🔍 Lấy thông tin danh sách command sẽ được thực thi"

    local apiPath="api/getCommandList?auth=${AUTH_KEY}"
    local response=$(call_api "GET" $apiPath)
    if [ $? -ne 0 ]; then
        log "ERROR" "❌ Không thể lấy trạng thái của worker $WORKER_NAME: $response"
    else
        log "DEBUG" "✅ Trạng thái của worker $WORKER_NAME: $response"
    fi
}


#Get status of specific worker
get_execution_command() {
    local index=$1
    log "INFO" "🔍 Lấy thông tin command sẽ được thực thi"

    local apiPath="api/getCommand?auth=${AUTH_KEY}&index=${index}"
    local response=$(call_api "GET" $apiPath)
    if [ $? -ne 0 ]; then
        log "ERROR" "❌ Không thể lấy trạng thái của worker $WORKER_NAME: $response"
    else
        log "DEBUG" "✅ Trạng thái của worker $WORKER_NAME: $response"
    fi
    # Extract data from response
    local command_id=$(echo $response | jq -r '.command')
    log "INFO"    "✅ Lệnh #$index: $command_id"
}

#Get status of specific worker
get_worker_status() {
    log "INFO" "🔍 Kiểm tra trạng thái của worker $WORKER_NAME"

    local apiPath="api/specificWorkerStatus?auth=${AUTH_KEY}" + "&workerId=${WORKER_NAME}"
    local response=$(call_api "GET" $apiPath)
    if [ $? -ne 0 ]; then
        log "ERROR" "❌ Không thể lấy trạng thái của worker $WORKER_NAME: $response"
    else
        log "DEBUG" "✅ Trạng thái của worker $WORKER_NAME: $response"
    fi
}

# Hàm thực thi lệnh với timeout
execute_with_timeout() {
    local command=$1
    local timeout=$2
    local cmdCount=$3
    local output_file="${LOG_DIR}/command_${cmdCount}_${WORKER_NAME}_output.log"

    log "INFO" "⏱️ Thực thi lệnh với timeout ${timeout}s: $command"

    # Sử dụng timeout command để giới hạn thời gian chạy
    #timeout $timeout bash -c "$command" >$output_file 2>&1
    (timeout $timeout bash -c "$command" 2>&1 | tee "$output_file"; exit ${PIPESTATUS[0]})
    local exit_code=$?

    if [ $exit_code -eq 124 ]; then
        log "ERROR" "⏰ Lệnh #$cmdCount đã vượt quá thời gian chờ (${timeout}s)"
        return 124
    elif [ $exit_code -ne 0 ]; then
        log "ERROR" "❌ Lệnh #$cmdCount thất bại với mã lỗi: $exit_code"
        log "DEBUG" "======= Nội dung lỗi ======="
        tail -n 30 $output_file | while IFS= read -r line; do
            log "DEBUG" "   $line"
        done
        log "DEBUG" "=========================="
        return $exit_code
    else
        log "INFO" "✅ Lệnh #$cmdCount thực thi thành công"
        return 0
    fi
}

# Update command
update_command() {
    local index=$1
    local command=$2
    local apiPath="/api/updateCommand?auth=${AUTH_KEY}"
    local data="{\"index\":\"${index}\",\"command\":\"${command}\"}"

    log "INFO" "🔄 Cập nhật lệnh #$index: $command"
    local response=$(call_api "POST" $apiPath "$data")
    if [ $? -ne 0 ]; then
        log "ERROR" "❌ Không thể cập nhật trạng thái lệnh: $response"
    else
        log "DEBUG" "✅ Đã cập nhật trạng thái lệnh: $response"
    fi
}

# Wait for all workers to be the same status
wait_for_all_workers() {
    local expStatus=$1
    local index=$2
    local maxWaitTime=${3:-$MAX_WAIT_TIME}
    log "INFO" "⏳ Chờ tất cả các worker khác sẵn sàng... with status: $expStatus"
    local wait_time=0
    while [ $wait_time -lt $maxWaitTime ]; do
        local all_worker_status=$(get_all_worker_status $expStatus $index)
        if [[ $all_worker_status == *"$expStatus"* ]]; then
            log "INFO" "✅ Tất cả các worker đã sẵn sàng: $all_worker_status"
            break
        fi
        sleep 20
        wait_time=$((wait_time + 20))
    done

    if [ $wait_time -ge $MAX_WAIT_TIME ]; then
        log "ERROR" "❌ Không thể đồng bộ status ($expStatus) với tất cả các worker trong thời gian quy định ($maxWaitTime giây)."
        exit 1
    fi
}

# Kiểm tra API server có hoạt động không
log "INFO" "🔍 Kiểm tra kết nối tới API server: $API_SERVER"
echo "GET request to ${API_SERVER}/health"
curl -s -w "%{http_code}" "${API_SERVER}/health"
echo
response=$(curl -s -w "%{http_code}" "${API_SERVER}/health")
status_code=${response: -3}

if [ "$status_code" != "200" ]; then
    log "ERROR" "❌ Không thể kết nối tới API server (HTTP $status_code). Vui lòng kiểm tra API server đã chạy chưa và các worker có thể truy cập không."
    exit 1
fi

log "INFO" "🚀 Bắt đầu thực thi hiệu năng trên worker $WORKER_NAME"
log "INFO" "✅ Kết nối tới API server thành công"
log "INFO" "🔄 Dọn dẹp trạng thái worker trước khi thực thi lệnh"
log "INFO" "✅ Tất cả các worker đã sẵn sàng"
sleep 10

# Đọc và thực thi từng lệnh trong file
cmdCount=0
total_success=0
total_failure=0
log "INFO" "🔄 Vincent Test: $COMMANDS_EXE"
# while true and break if status of command is COMPLETED
line="$COMMANDS_EXE $WORKER_NAME_EXE"
log "INFO" "🔄 Vincent Test: $line"
# Replace {ExecutionDate} with TIMESTAMP
line=${line//\{ExecutionDate\}/$TIMESTAMP}

log "INFO"    "✅ Start execution:  $line"

# Check whether the line is a command and have a timeout
# Format: TIMEOUT=3600; actual_command
timeout_value=$DEFAULT_TIMEOUT

if [[ "$line" =~ ^TIMEOUT=([0-9]+)[[:space:]]*\; ]]; then
    timeout_value="${BASH_REMATCH[1]}"
    # Remove the timeout part from the line
    line="${line#TIMEOUT=$timeout_value; }"
fi

log "INFO" "-------------------------------------------------------------------------"
log "INFO" "▶️ Chuẩn bị thực thi lệnh (timeout: ${timeout_value}s): $line"

# Uppdate worker status IDLE
update_worker_status "$cmdCount" "IDLE"

# Wait for all workers to be IDLE
wait_for_all_workers "IDLE" $cmdCount
sleep 30        #wait for 30 seconds before executing the command to sync all workers

# Đánh dấu worker đã sẵn sàng
log "INFO" "🔄 Đánh dấu worker $WORKER_NAME đã sẵn sàng cho lệnh: $line"
update_worker_status "$cmdCount" "READY"

# Wait for all workers to be ready
wait_for_all_workers "READY" $cmdCount

# Execute the command after all workers are ready
sleep 30        #wait for 30 seconds before executing the command to sync all workers
update_worker_status "$cmdCount" "RUNNING"

# Start executing the command
command_start=$(date +"%Y-%m-%d %H:%M:%S")
log "INFO" "🏃 Đang thực thi lệnh : $line lúc $command_start"
execute_with_timeout "$line" "$timeout_value" "$cmdCount"
result=$?
command_end=$(date +"%Y-%m-%d %H:%M:%S")

# Đánh dấu lệnh đã hoàn thành
update_worker_status "$cmdCount" "COMPLETED"
log "INFO" "✅ Lệnh #$cmdCount đã hoàn thành lúc $command_end"
if [ $result -eq 0 ]; then
    log "INFO" "✅ Lệnh #$command_id thực thi thành công"
    total_success=$((total_success + 1))
else
    if [ $result -eq 124 ]; then
        log "ERROR" "⏰ Lệnh #$command_id đã vượt quá thời gian chờ (${timeout_value}s)"
    else
        log "ERROR" "❌ Lệnh #$command_id thất bại với mã lỗi: $result"
    fi
    total_failure=$((total_failure + 1))
fi

# Update command status: COMPLETED
wait_for_all_workers "COMPLETED" $cmdCount
log "INFO" "⏳ Chờ 180 giây trước khi chuẩn bị lệnh tiếp theo..."
sleep 180
update_worker_status "$cmdCount" "IDLE"

# Trả về mã lỗi
if [ $total_failure -eq 0 ]; then
    exit 0
else
    exit 1
fi
