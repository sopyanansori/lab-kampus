FROM php:7.4-apache

LABEL maintainer="Nura Wiguna Saputra"

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install --fix-missing -y libpq-dev
RUN apt-get install --no-install-recommends -y libpq-dev
RUN apt-get install -y libxml2-dev libbz2-dev zlib1g-dev
RUN apt-get -y install libsqlite3-dev libsqlite3-0 mariadb-client curl exif ftp
RUN docker-php-ext-install intl
RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN docker-php-ext-enable mysqli
RUN docker-php-ext-enable pdo
RUN docker-php-ext-enable pdo_mysql
RUN apt-get -y install --fix-missing zip unzip
RUN apt-get -y install --fix-missing git

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer self-update --2

ADD conf/apache.conf /etc/apache2/sites-available/000-default.conf

# LDAP INSTALLATION
# RUN set -x \
#     && apt-get update \
#     && apt-get install -y libldap2-dev \
#     && rm -rf /var/lib/apt/lists/* \
#     && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
#     && docker-php-ext-install ldap \
#     && apt-get purge -y --auto-remove libldap2-dev

RUN a2enmod rewrite

#ADD startScript.sh /startScript.sh
# The printf command below creates the script /startScript.sh with the following 3 lines. 
# #!/bin/bash
# mv /pustaka-booking /var/www/html
# /usr/sbin/apache2ctl -D FOREGROUND
RUN printf "#!/bin/bash\nmv /pustaka-booking /var/www/html\n/usr/sbin/apache2ctl -D FOREGROUND" > /startScript.sh
RUN chmod +x /startScript.sh

RUN cd /var/www/html

RUN composer create-project pustaka-booking/appstarter pustaka-booking v4.1.8
RUN chmod -R 0777 /var/www/html/pustaka-booking/writable

RUN mv pustaka-booking /

RUN apt-get clean \
    && rm -r /var/lib/apt/lists/*
    
EXPOSE 80
VOLUME ["/var/www/html", "/var/log/apache2", "/etc/apache2"]

CMD ["bash", "/startScript.sh"]