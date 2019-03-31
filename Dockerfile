FROM ganesh891/httpd_new1:latest
COPY /tmp/workspace/devproject/ /usr/local/apache2/htdocs
EXPOSE 80
