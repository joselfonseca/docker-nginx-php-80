FROM ubuntu:20.04

RUN apt-get clean && apt-get -y update && apt-get install -y locales && locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' LC_ALL='en_US.UTF-8'

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y nginx curl zip unzip git software-properties-common supervisor sqlite3 libxrender1 libxext6 mysql-client libssh2-1-dev autoconf libz-dev\
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y php8.0-fpm php8.0-cli php8.0-gd php8.0-mysql php8.0-intl php8.0-pgsql \
       php8.0-imap php-memcached php8.0-mbstring php8.0-xml php8.0-curl \
       php8.0-sqlite3 php8.0-zip php8.0-pdo-dblib php8.0-bcmath php8.0-ssh2 php8.0-dev php8.0-redis php-pear \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && mkdir /run/php

RUN update-ca-certificates

RUN apt-get remove -y --purge software-properties-common \
	&& apt-get -y autoremove \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& echo "daemon off;" >> /etc/nginx/nginx.conf


RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY default /etc/nginx/sites-available/default

COPY php-fpm.conf /etc/php/8.0/fpm/php-fpm.conf

COPY www.conf /etc/php/8.0/fpm/pool.d/www.conf

COPY php.ini /etc/php/8.0/fpm/php.ini

EXPOSE 80

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]
