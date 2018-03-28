#!/bin/bash
mkdir /run/php-fpm
/etc/rc.d/init.d/spawn-fcgi start
php-fpm 
nginx -g "daemon off;"
