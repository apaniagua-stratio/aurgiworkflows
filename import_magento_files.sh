#!/bin/sh

	magentopath="/var/www/magentodev"
	magentourl="https://stratio-dev.motortown.es"
        ftp_site="10.20.1.112"
        username="motortown_watcher"
#source path
        spath="./var/import"
#Remote Path
        rpath="/anjana/motortown_pro/ingesta_productos_stock/procesado"

        cd $spath

        fileName=$(echo "ls -1rt" | sftp $username@$ftp_site:$rpath | grep "magento_csv_products" | tail -1) 
	fileNameStock=$(echo "ls -1rt" | sftp $username@$ftp_site:$rpath | grep "magento_csv_stock" | tail -1)

	echo -e "\nstart of log\n"
	echo "get $fileName" | sftp $username@$ftp_site:$rpath/$fileName /var/www/magentodev/var/import/product/current.csv  
	echo "get $fileNameStock" | sftp $username@$ftp_site:$rpath/$fileNameStock /var/www/magentodev/var/import/avilability/current.csv 
	
	echo -e "\nCurl custom product import:"  
	curl $magentourl/Customcart/Import/product
	sleep 180
	#echo -e "\nOutput of system.log: "
	#tail $magentopath/var/log/system.log | grep "STRATIO-products" 

	echo -e "\nCurl custom stock import:"
	curl $magentourl/Customcart/Import/availabilitysingle
	sleep 180
	echo -e "\nOutput of system.log: "
	tail -n 50 $magentopath/var/log/system.log | grep "STRATIO"
							
	#$magentopath/php bin/magento indexer:reindex

	exit
        EOF
        echo "Success : $?"

