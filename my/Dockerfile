FROM nginx:latest

COPY index.xml /var/www/html/
COPY nginx.conf /etc/nginx/nginx.conf
COPY site.conf server.crt /etc/nginx/conf.d/
COPY server.crt server.key /etc/nginx/

