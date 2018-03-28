#!/bin/bash
/etc/rc.d/init.d/spawn-fcgi start
/etc/init.d/php-fpm start
nginx -g "daemon off;"
