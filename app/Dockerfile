FROM ubuntu:20.04
RUN apt-get -y update && apt-get -y install nginx && apt-get clean
COPY default /etc/nginx/sites-available/default
COPY index.html img /usr/share/nginx/html/
EXPOSE 80/tcp
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]