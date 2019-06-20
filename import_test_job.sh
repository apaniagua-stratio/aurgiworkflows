#!/bin/sh
magentopath="/var/www/magentodev"
hoy=`date +%Y_%m_%d_%H_%M`

$magentopath/var/import/import_test.sh > $magentopath/var/log/import_$hoy.log

echo -e "\nFinished job" >> $magentopath/var/log/import_$hoy.log