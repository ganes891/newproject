FROM ganesh891/httpd:latest
COPY /tmp/workspace/devproject/ /usr/local/apache2/htdocs/
EXPOSE 80
