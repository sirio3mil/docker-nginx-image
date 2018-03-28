#!/bin/bash
/etc/rc.d/init.d/spawn-fcgi start
nginx -g "daemon off;"
