#!/bin/sh
magentopath="/var/www/magentodev"
hoy=`date +%Y_%m_%d_%H_%M`

$magentopath/import_magento_files.sh > $magentopath/var/log/import_$hoy.log

php bin/magento indexer:reindex >> $magentopath/var/log/import_$hoy.log

echo -e "\nFinished job" >> $magentopath/var/log/import_$hoy.log

