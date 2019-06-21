#!/bin/sh

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
	   if grep -q ${arr[$i]} "$magentopath/var/import/ficheros_leidos.txt"; 
	   then
   	   	echo "${arr[$i]} already imported."
	   else
 	        echo "${arr[$i]} is new and will be imported."
		echo "get ${arr[$i]}" | sftp $username@$ftp_site:$rpath/${arr[$i]} $magentopath/var/import/product/current.csv  
		curl $magentourl/Customcart/Import/product
	        sleep 90 
		
		echo ${arr[$i]} >> $magentopath/var/import/ficheros_leidos.txt

		break
	   fi	
	done
	
	echo " --- "


	declare -a arrStock=($filelistStock)
        arraylengthStock=${#arrStock[@]}

        for (( j=0; j<${arraylengthStock}; j++ ))
        do
           # copiar solo si no esta en lista de leidos
           if grep -q ${arrStock[$j]} "$magentopath/var/import/ficheros_leidos.txt"; 
           then
                echo "${arrStock[$j]} already imported."
           else
                echo "${arrStock[$j]} is new and will be imported."
                echo ${arrStock[$j]} >> $magentopath/var/import/ficheros_leidos.txt
                echo "get ${arrStock[$j]}" | sftp $username@$ftp_site:$rpath/${arrStock[$j]} $magentopath/var/import/avilability/current.csv  
                curl $magentourl/Customcart/Import/availabilitysingle
                sleep 90

                break
           fi   
        done
	
	echo -e "\nOutput of system.log: "
	tail -n 20 $magentopath/var/log/system.log | grep "STRATIO"
							
	echo "Success : $?"

	exit
        EOF
        echo "Success : $?"
