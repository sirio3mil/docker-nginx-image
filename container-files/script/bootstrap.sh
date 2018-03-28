#!/bin/bash
service spawn-fcgi start
service php-fpm start
nginx -g "daemon off;"
