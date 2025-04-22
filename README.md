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
