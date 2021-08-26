# vim: set ft=dockerfile:
FROM alpine:3.10
# Author with no obligation to maintain
LABEL author="Paul Tötterman <paul.totterman@iki.fi>"

ENV VERSION="0.21.5" \
    DBHOST="mariadb" \
    DBNAME="racktables" \
    DBUSER="racktables" \
    DBPASS="" \
    DBPORT="3306"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN apk --no-cache add ca-certificates curl php7-bcmath php7-curl php7-fpm php7-gd php7-json php7-ldap php7-mbstring \
    php7-pcntl php7-pdo_mysql php7-session php7-snmp nginx

COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /opt/racktables
RUN curl -sSL "https://github.com/RackTables/racktables/archive/RackTables-$VERSION.tar.gz" | tar xzv --strip-components=1 -C /opt/racktables
RUN sed -i -e 's|^listen =.*$|listen = 9000|' /etc/php7/php-fpm.d/www.conf
RUN sed -i -e 's|^;daemonize = .*|daemonize = no|' /etc/php7/php-fpm.conf

VOLUME /opt/racktables/wwwroot
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/php-fpm7"]
