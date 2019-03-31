docker login -u ganesh891 -p ganesh-1
docker commit job5 httpd_new1
docker tag httpd_new1 ganesh891/httpd_new1
docker push ganesh891/httpd_new1
docker stop job5
docker rm job5
docker build -t httpddev:devproject /tmp/workspace/devproject/
docker run -dit --name job6 -p 80:80 httpddev:devproject
