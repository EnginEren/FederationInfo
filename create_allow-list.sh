#!/bin/bash

#cd /var/www/html/parser
BASE=/root
FEDINFO=/root/FederationInfo
export XRD_NETWORKSTACK=IPv4

declare -a redirectors=("cms-xrd-global.cern.ch:1094" "cms-xrd-transit.cern.ch:1094")

for j in "${redirectors[@]}";do
	if [ "$j" == "cms-xrd-global.cern.ch:1094" ]; then
		xrdmapc --list all "$j" | grep Man  | awk '{print $3}' > $BASE/tmp_manlist
		for i in $(cat $BASE/tmp_manlist);do
		 	word=$(echo $i | cut -d ":" -f1 | awk -F"." '{print $NF}')	
			if [ $word == "edu" ] || [ $word == "gov" ] || [ $word == "br" ] ;then
				xrdmapc --list all $i > $BASE/tmp_us_$i	
				cat $BASE/tmp_us_$i | awk '{if($2=="Man") print $3; else print $2}' | tail -n +2 >> $BASE/tmp_total_us
			else
				xrdmapc --list all $i > $BASE/tmp_$i	
				cat $BASE/tmp_$i | awk '{if($2=="Man") print $3; else print $2}' | tail -n +2 >> $BASE/tmp_total_eu
			fi
		done
	

		cat $BASE/tmp_total_eu | cut -d : -f1 | sort -u > $FEDINFO/in/prod.txt 
		cat $BASE/tmp_total_us | cut -d : -f1 | sort -u >> $FEDINFO/in/prod.txt 
		cat $BASE/tmp_total_eu | cut -d : -f1 | sort -u | awk -F. '{print "cms.allow host " "*."$(NF-1)"."$NF}' | sort -u > $FEDINFO/out/list_eu.allow
		cat $BASE/tmp_total_us | cut -d : -f1 | sort -u | awk -F. '{print "cms.allow host " "*."$(NF-1)"."$NF}' | sort -u > $FEDINFO/out/list_us.allow

	else
		xrdmapc --list all "$j" | tail -n +2 | awk '{if($2=="Man") print $3; else print $2}' > $BASE/tmp_total
		cat $BASE/tmp_total | cut -d : -f1 | sort -u > $FEDINFO/in/trans.txt
	fi	
	  

	rm $BASE/tmp_*

done




exit 0;
