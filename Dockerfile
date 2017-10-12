FROM nginx:1.11

RUN echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list && \
    echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list && \
    apt-get update -y && \
    apt-get install -y apt-transport-https lsb-release ca-certificates wget curl && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    wget https://www.dotdeb.org/dotdeb.gpg && apt-key add dotdeb.gpg && \
    # Add any other required packages here, e.g. php7.0-memcached
    apt-get update && apt-get install -y --force-yes git curl php7.1-fpm php7.1-cli \
            php7.1-common php7.1-mbstring php7.1-xml php7.1-bcmath \
            mcrypt php7.1-mcrypt php7.1-curl gzip php7.1-mysql zip unzip php7.1-zip nano && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/bin/composer && \
    # PHP-FPM settings
    sed -i "/user  nginx;/c user  root;"                           /etc/nginx/nginx.conf && \
    sed -i "/memory_limit = /c memory_limit = 128M"                /etc/php/7.1/fpm/php.ini && \
    sed -i "/max_execution_time = /c max_execution_time = 300"     /etc/php/7.1/fpm/php.ini && \
    sed -i "/upload_max_filesize = /c upload_max_filesize = 50M"   /etc/php/7.1/fpm/php.ini && \
    sed -i "/post_max_size = /c post_max_size = 50M"               /etc/php/7.1/fpm/php.ini && \
    sed -i "/user = /c user = root"                                /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i "/;listen.mode = /c listen.mode = 0666"                 /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i "/listen.owner = /c listen.owner = root"                /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i "/listen.group = /c listen.group = root"                /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i "/listen = /c listen = 127.0.0.1:9000"                  /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i "/;clear_env = /c clear_env = no"                       /etc/php/7.1/fpm/pool.d/www.conf && \
    # Log aggregation
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    ln -sf /dev/stdout /var/log/php7.1-fpm.log && \
    # Setup permissions
    mkdir /.composer /run/php && \
    chmod -R g+ws /run/php /var/run /etc/nginx/conf.d /var/cache/nginx /var/log /.composer && \
    chown -R 1001:0 /run/php /var/run /etc/nginx/conf.d /var/cache/nginx /var/log /.composer

EXPOSE 8080

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
CMD ["/start.sh"]

ENV TZ=Asia/Tehran
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    sed -i "/;date.timezone =/c date.timezone = Asia/Tehran;" /etc/php/7.1/fpm/php.ini && \
    sed -i "/;date.timezone =/c date.timezone = Asia/Tehran;" /etc/php/7.1/cli/php.ini

COPY ./site.conf /etc/nginx/conf.d/default.conf
COPY ./start.sh ./entrypoint.sh /
RUN chmod +x start.sh entrypoint.sh

WORKDIR /var/www

# Install dependency
#COPY composer.json ./
#RUN composer install --no-scripts --no-autoloader --prefer-dist --no-dev --working-dir=/var/www

# Copy the app files
#COPY . /tmp/app
#RUN chmod -R ug+rwx /tmp/app && \
#    chown -R 1001:0 /tmp/app && \
#    cp -rpT /tmp/app /var/www && \
#    rm -rf /tmp/app && \
#    composer dump-autoload --optimize

RUN echo "<?php phpinfo(); ?>" >> public/index.php
RUN chmod g+w public/index.php

USER 1001