FROM httpd:devproject8
COPY . /usr/local/apache2/htdocs/
EXPOSE 80
