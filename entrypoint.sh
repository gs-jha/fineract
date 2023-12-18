#!/bin/sh
set -ex

# while ! nc -zvw3 "${FINERACT_DEFAULT_TENANTDB_HOSTNAME:-fineractmysql}" "${FINERACT_DEFAULT_TENANTDB_PORT:-3306}" ; do
#     echo "DB Server is unavailable - sleeping"
#     sleep 5
# done
# echo "DB Server is up - executing command"

#java -cp "app:app/lib/*" org.apache.fineract.ServerApplication

ls -al

#java -Dloader.path=libs/ -jar fineract-provider*.jar
java -Dloader.path=/app/libs/ -jar /app/fineract-provider*.jar

# java -Dloader.path=build/run/lib/ -jar build/run/fineract-provider*.jar
