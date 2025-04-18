#!/bin/bash
#sudo chmod u+w jmeter
docker stop testek-jmeter-nginx
docker rm -f testek-jmeter-nginx
docker run -d \
  --name testek-jmeter-nginx \
  -v /Users/vincent/Work/shb/workspace/perf-test/jmeter/deployment/nginx-docker/conf/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v /Users/vincent/Work/shb/workspace/perf-test/jmeter/res:/usr/share/nginx/html:ro \
  -p 8081:80 \
  nginx