cd /tmp/workspace/devproject/
cd ../
cd -
docker login -u ganesh891 -p ganesh-1
docker commit job12 httpd_new1
docker tag httpd_new12 ganesh891/http_new12
docker push ganesh891/httpd_new12
docker stop job12
docker rm job12
docker pull ganesh891/httpd
docker tag ganesh891/httpd ganesh891/httpd_devproj:1955pm
docker run -dit --name job6 -p 80:80 -v /tmp/workspace/devproject/:/usr/local/apache2/htdocs ganesh891/httpd_devproj:1955pm



