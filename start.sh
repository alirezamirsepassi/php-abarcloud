#!/bin/bash

php-fpm7.1 --allow-to-run-as-root --fpm-config /etc/php/7.1/fpm/php-fpm.conf &
nginx -g "daemon off;"