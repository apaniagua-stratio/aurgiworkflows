#!/bin/sh

	now=$(date +"%T")
	echo "Start time : $now"

	magentopath="/var/www/magentodev"
	magentourl="https://stratio-dev.motortown.es"
        ftp_site="10.20.1.112"
        username="motortown_watcher"
#source path
        spath="./var/import"
#Remote Path
        rpath="/anjana/motortown_pro/ingesta_productos_stock/procesado"

	
        fileName=$(echo "ls -1" | sftp $username@$ftp_site:$rpath | grep "magento_csv_products" | tail -1) 
	fileNameStock=$(echo "ls -1" | sftp $username@$ftp_site:$rpath | grep "magento_csv_stock" | tail -1)
	
	filelist=$(echo "ls -1" | sftp $username@$ftp_site:$rpath | grep "magento_csv_products")	
	filelistStock=$(echo "ls -1" | sftp $username@$ftp_site:$rpath | grep "magento_csv_stock")

	declare -a arr=($filelist)
	arraylength=${#arr[@]}

	for (( i=0; i<${arraylength}; i++ ))
	do
	   # copiar solo si no esta en lista de leidos
	   if grep -q ${arr[$i]} "$magentopath/var/import/PROCESSED_FILES"; 
	   then
   	   	echo "${arr[$i]} already imported."
	   else
 	        echo "${arr[$i]} is new and will be imported."
		echo "get ${arr[$i]}" | sftp $username@$ftp_site:$rpath/${arr[$i]} $magentopath/var/import/product/current.csv  
		curl $magentourl/Customcart/Import/product
	        sleep 75 
		
		echo ${arr[$i]} >> $magentopath/var/import/PROCESSED_FILES
		INGESTED_PRODUCT_FILE=${arr[$i]}
		export INGESTED_PRODUCT_FILE

		break
	   fi	
	done
	
	echo "Finished products, starting availability"


	declare -a arrStock=($filelistStock)
        arraylengthStock=${#arrStock[@]}

        for (( j=0; j<${arraylengthStock}; j++ ))
        do
           # copiar solo si no esta en lista de leidos
           if grep -q ${arrStock[$j]} "$magentopath/var/import/PROCESSED_FILES"; 
           then
                echo "${arrStock[$j]} already imported."
           else
                echo "${arrStock[$j]} is new and will be imported."
                echo "get ${arrStock[$j]}" | sftp $username@$ftp_site:$rpath/${arrStock[$j]} $magentopath/var/import/avilability/current.csv  
                curl $magentourl/Customcart/Import/availabilitysingle
                sleep 75

		echo ${arrStock[$j]} >> $magentopath/var/import/PROCESSED_FILES
	 	export INGESTED_STOCK_FILE=${arrStock[$i]}

                break
           fi   
        done
	
	echo -e "\nOutput of system.log: "
	tail -n 18 $magentopath/var/log/system.log | grep "STRATIO"
							
	echo "Success : $?"
	now=$(date +"%T")
	echo "End time : $now"

	exit
        EOF

