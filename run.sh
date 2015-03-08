#!/bin/bash

if [[ ! -f /mysql/my.cnf ]]; then
    echo "==> no my.cnf in data volumne, initializing"
    sed -e '/^bind-address/c\bind-address=0.0.0.0' \
        -e '/^log_bin/s/^/\#/' \
        -e 's/\/var\/run\/mysqld/\/mysql\/run/' \
        -e 's/\/var\/log\/mysql/\/mysql\/log/' \
        -e 's/\/var\/lib\/mysql/\/mysql\/data/' < /etc/mysql/my.cnf > /mysql/my.cnf
else
    echo "==> using provided my.cnf"
fi

install -d -m 0755 -o mysql -g mysql /mysql/log /mysql/run

if [[ ! -d /mysql/data/mysql ]]; then
    echo "==> no database found, initialising"
    mysql_install_db --defaults-file=/mysql/my.cnf >/mysql/log/mysql_install_db.log 2>&1
else
    echo "==> using existing data volume"
fi


echo "==> starting mysqld"
exec /usr/sbin/mysqld --defaults-file=/mysql/my.cnf
