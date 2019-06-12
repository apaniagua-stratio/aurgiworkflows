#!/bin/sh

        ftp_site="10.20.1.112"
        username="motortown_watcher"
#source path
        spath="./var/import"
#Remote Path
        rpath="/anjana/motortown_pro/ingesta_productos_stock/procesado"

        cd $spath

        fileName=$(echo "ls -1rt" | sftp $username@$ftp_site:$rpath | grep "magento_csv_products" | tail -1)
        fileNameStock=$(echo "ls -1rt" | sftp $username@$ftp_site:$rpath | grep "magento_csv_stock" | tail -1)

        echo "get $fileName" |sftp $username@$ftp_site:$rpath/$fileName /var/www/magentodev/var/import/product/current.csv
        echo "get $fileNameStock" |sftp $username@$ftp_site:$rpath/$fileNameStock /var/www/magentodev/var/import/avilability/current.csv

        echo "curl custom product import:" 
        curl https://stratio-dev.motortown.es/Customcart/Import/product
        sleep 5

        echo "curl custom stock import:"
        curl https://stratio-dev.motortown.es/Customcart/Import/availabilitysingle
        exit
        EOF
        echo "Success : $?"

