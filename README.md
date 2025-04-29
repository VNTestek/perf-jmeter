### Introduce


### How to setup
1. Install java 11 -> Download tại Testek_Google_Drive(https://drive.google.com/drive/folders/1q2v0r7X3gk4j5x6m8z9f8n7h8g3h4j5?usp=sharing)
2. Clone (or Download zip) project về máy
3. Install Grafana & InfluxDB tại Testek_Google_Drive(https://drive.google.com/drive/folders/1q2v0r7X3gk4j5x6m8z9f8n7h8g3h4j5?usp=sharing)
   1. Chạy InfluxDB
   2. Chạy Grafana

### How to run
1. Config InfluxDB
   1. Chạy InfluxDB
   2. Mở trình duyệt và truy cập vào địa chỉ http://localhost:8086
   3. Tạo database với tên là `testek`
   4. Tạo user với username là `testek` và password là `testek`
   5. Tạo token với quyền write cho database `testek`
2. Config Grafana
   1. Chạy Grafana
   2. Mở trình duyệt và truy cập vào địa chỉ http://localhost:3000
   3. Đăng nhập với username là `admin` và password là `admin`
   4. Thay đổi password
   5. Tạo datasource với tên là `testek` và chọn loại là `InfluxDB`
   6. Nhập địa chỉ InfluxDB là `http://localhost:8086` và database là `testek`
   7. Tạo dashboard với tên là `testek`
3. Config project
   1. Mở file `src/main/resources/application.properties`
   2. Thay đổi các thông số sau:
      - influxdb.url: địa chỉ InfluxDB
      - influxdb.token: token của InfluxDB
      - influxdb.org: org của InfluxDB
      - influxdb.bucket: bucket của InfluxDB

sudo apt update
sudo apt install nodejs npm
Tạo Thư Mục Dự Án
Copy# Tạo thư mục cho API server
mkdir -p /opt/jenkins-sync-api
cd /opt/jenkins-sync-api

# Khởi tạo dự án Node.js
npm init -y
1.3. Cài Đặt Các Gói Phụ Thuộc
Copy# Cài đặt Express và các gói cần thiết
npm install express body-parser cors morgan winston

Tạo File Mã Nguồn Server
Tạo file server.js

Sử Dụng PM2 (Giải Pháp Tốt Nhất)
PM2 là một công cụ quản lý quy trình Node.js mạnh mẽ, ổn định hơn việc tự quản lý process:

Copy# Cài đặt PM2 toàn cục
sudo npm install -g pm2

# Chạy API server với PM2
cd /home/vincent/ws/jenkins/jenkins-sync-api
pm2 start server.js --name jenkins-sync-api

# Lưu cấu hình để tự khởi động khi boot
pm2 save
pm2 startup
PM2 cung cấp các tính năng hữu ích như:

Tự động khởi động lại khi server crash
Quản lý logs dễ dàng
Theo dõi hiệu suất
Tự động khởi động khi hệ thống boot
Để xem logs và trạng thái:

Copypm2 logs jenkins-sync-api
pm2 status

Jenkins TOken: 110ed92afa26d0e44e6bb730d92816cb59
