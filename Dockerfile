FROM ganesh/httpd:latest
COPY . /usr/local/apache2/htdocs/
EXPOSE 80
