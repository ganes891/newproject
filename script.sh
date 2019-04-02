cd /tmp/workspace/devproject/
cd ../
cd -
#docker login -u ganesh891 -p ganesh-1
#docker commit job7 httpd_7
#docker tag httpd_7 ganesh891/httpd_7
#docker push ganesh891/httpd_7
#docker stop job7
#docker rm job7
#sleep 10
#docker build -t httpd:devproject8 /tmp/workspace/devproject/
#docker tag httpd:devproject8 ganesh891/httpd_08_image
#docker run -dit --name job8 -p 80:80 ganesh891/httpd_08_image
#sleep 5
docker cp /tmp/workspace/devproject/index.html job7:/usr/local/apache2/htdocs/

