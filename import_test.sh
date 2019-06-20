#!/bin/sh

	magentopath="/var/www/magentodev"
	magentourl="https://stratio-dev.motortown.es"
        ftp_site="10.20.1.112"
        username="motortown_watcher"
#source path
        spath="./var/import"
#Remote Path
        rpath="/anjana/motortown_pro/ingesta_productos_stock/procesado"

	
        fileName=$(echo "ls -1rt" | sftp $username@$ftp_site:$rpath | grep "magento_csv_products" | tail -1) 
	fileNameStock=$(echo "ls -1rt" | sftp $username@$ftp_site:$rpath | grep "magento_csv_stock" | tail -1)
	
	filelist=$(echo "ls -1rt" | sftp $username@$ftp_site:$rpath | grep "magento_csv_products")	

	echo " ---on sftp: "
	declare -a arr=($filelist)
	arraylength=${#arr[@]}
	echo "length: $arraylength"

	for (( i=0; i<${arraylength}+1; i++ ))
	do
	   echo "fichero: $i : " ${arr[$i-1]}
	   # copiar solo si no esta en lista de leidos
	   if grep -q ${arr[$i-1]} "/var/www/magentodev/var/import/ficheros_leidos.txt"; 
	   then
   	   	echo "${arr[$i-1]} esta ya ficheros leidos"
	   else
 	        echo "${arr[$i-1]} no esta en fichero, se ingestará"
		echo ${arr[$i-1]} >> /var/www/magentodev/var/import/ficheros_leidos.txt
		echo "get ${arr[$i-1]}" | sftp $username@$ftp_site:$rpath/${arr[$i-1]} $magentopath/var/import/product/current.csv  
		curl $magentourl/Customcart/Import/product
	        sleep 180
		echo -e "\nOutput of system.log: "
        	tail -n 50 $magentopath/var/log/system.log | grep "STRATIO"

		break
	   fi	
	done
	
	echo " --- "




	
	#echo -e "\nstart of log\n"
	#echo "get $fileName" | sftp $username@$ftp_site:$rpath/$fileName $magentopath/var/import/test/product_$fileName  
	#echo "get $fileNameStock" | sftp $username@$ftp_site:$rpath/$fileNameStock $magentopath/var/import/test/stock_$fileNameStock 

	
	#echo -e "\nCurl custom product import:"  
	#curl $magentourl/Customcart/Import/product
	#sleep 180
	 

	#echo -e "\nCurl custom stock import:"
	#curl $magentourl/Customcart/Import/availabilitysingle
	#sleep 180
	#echo -e "\nOutput of system.log: "
	#tail -n 50 $magentopath/var/log/system.log | grep "STRATIO"
							
	echo "Success : $?"

	exit
        EOF
#        echo "Success : $?"