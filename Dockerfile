FROM nginx:latest


MAINTAINER Samúel Jón Gunnarsson <samuel.jon.gunnarsson@gmail.com>

LABEL Description="Container for running nginx with drupal specific configuration. \
Used with linked php-fpm container" 
LABEL version="1.0"

# Define a user with same user id as on the container host that ownes the data.
# If you change the name of the user you must change the config files accordingly.
ENV CONTAINER_USER runner
ENV CONTAINER_UID 1000

# Create the user and folder structure where the data will be placed.
RUN useradd --uid $CONTAINER_UID --groups www-data $CONTAINER_USER
RUN mkdir -p /websites
CMD chown $CONTAINER_USER.$CONTAINER_USER /websites

# Add overriding nginx config files
RUN rm /etc/nginx/conf.d/default.conf
ADD ./nginx-site.conf /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/nginx.conf
ADD ./nginx.conf /etc/nginx/nginx.conf
# Add SSL keys.
RUN mkdir /etc/nginx/ssl
ADD nginx.crt /etc/nginx/ssl/nginx.crt
ADD nginx.key /etc/nginx/ssl/nginx.key
RUN chmod 600 /etc/nginx/ssl/nginx.key

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
