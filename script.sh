cd /tmp/workspace/devproject/
cd ../
cd -
docker login -u ganesh891 -p ganesh-1
docker commit job6 httpd_20
docker tag httpd_6 ganesh891/httpd_6
docker push ganesh891/httpd_6
docker stop job6
docker rm job6
docker build -t httpd:devproject7 /tmp/workspace/devproject/
docker tag httpd:devproject7 ganesh891/httpd_07_image
docker run -dit --name job6 -p 80:80 -v /tmp/workspace/devproject/:/usr/local/apache2/htdocs ganesh891/httpd_07_image
sleep 5
docker cp /tmp/workspace/devproject/. job7:/usr/local/apache2/htdocs
