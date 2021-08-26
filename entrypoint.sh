#!/bin/sh -e

: "${DBNAME:=racktables}"
: "${DBHOST:=mariadb}"
: "${DBPORT:=3306}"
: "${DBUSER:=racktables}"

if [ ! -e /opt/racktables/wwwroot/inc/secret.php ]; then
    cat > /opt/racktables/wwwroot/inc/secret.php <<EOF
<?php
\$pdo_dsn = 'mysql:host=${DBHOST};port=${DBPORT};dbname=${DBNAME}';
\$db_username = '${DBUSER}';
\$db_password = '${DBPASS}';
\$user_auth_src = 'database';
\$require_local_account = TRUE;
\$pdo_= TRUE;

# See https://wiki.racktables.org/index.php/RackTablesAdminGuide
?>
EOF
fi

# Ugly hack to disable SSL cert verification
sed -i 's/$dbxlink = new PDO ($pdo_dsn, $db_username, $db_password, $drvoptions);/$dbxlink = new PDO ($pdo_dsn, $db_username, $db_password, array(PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => false));/g' /opt/racktables/wwwroot/inc/pre-init.php

chmod 0400 /opt/racktables/wwwroot/inc/secret.php
chown nobody:nogroup /opt/racktables/wwwroot/inc/secret.php

echo 'To initialize the db, first go to /?module=installer&step=5'

nginx

echo "$@"
exec "$@"
