#!/bin/bash

#cd /var/www/html/parser
BASE=/root
FEDINFO=/root/FederationInfo
export XRD_NETWORKSTACK=IPv4

declare -a redirectors=("xrdcmsglobal01.cern.ch:1094" "xrdcmsglobal02.cern.ch:1094" "cms-xrd-transit.cern.ch:1094")

for j in "${redirectors[@]}";do
	if [ "$j" == "xrdcmsglobal01.cern.ch:1094" ] || [ "$j" == "xrdcmsglobal02.cern.ch:1094" ]; then
		xrdmapc --list all "$j" | grep Man  | awk '{print $3}' > $BASE/tmp_manlist_$j
		for i in $(cat $BASE/tmp_manlist_$j);do
		 	word=$(echo $i | cut -d ":" -f1 | awk -F"." '{print $NF}')	
			if [ $word == "edu" ] || [ $word == "gov" ] || [ $word == "br" ] ;then
				xrdmapc --list all $i > $BASE/tmp_us_$i	
				cat $BASE/tmp_us_$i | awk '{if($2=="Man") print $3; else print $2}' | tail -n +2 >> $BASE/tmp_total_us_$j
			else
				xrdmapc --list all $i > $BASE/tmp_$i	
				cat $BASE/tmp_$i | awk '{if($2=="Man") print $3; else print $2}' | tail -n +2 >> $BASE/tmp_total_eu_$j
			fi
		done
	

		cat $BASE/tmp_total_eu_$j | cut -d : -f1 | sort -u > $FEDINFO/in/prod_$j.txt 
		cat $BASE/tmp_total_us_$j | cut -d : -f1 | sort -u >> $FEDINFO/in/prod_$j.txt 
		cat $BASE/tmp_total_eu_$j | cut -d : -f1 | sort -u | awk -F. '{print "cms.allow host " "*."$(NF-1)"."$NF}' | sort -u > $FEDINFO/out/list_eu_$j.allow
		cat $BASE/tmp_total_us_$j | cut -d : -f1 | sort -u | awk -F. '{print "cms.allow host " "*."$(NF-1)"."$NF}' | sort -u > $FEDINFO/out/list_us_$j.allow

	else
		xrdmapc --list all "$j" | tail -n +2 | awk '{if($2=="Man") print $3; else print $2}' > $BASE/tmp_total
		cat $BASE/tmp_total | cut -d : -f1 | sort -u > $FEDINFO/in/trans.txt
	fi	
	  

	rm $BASE/tmp_*

done


diff $FEDINFO/in/prod_xrdcmsglobal01.cern.ch\:1094.txt $FEDINFO/in/prod_xrdcmsglobal01.cern.ch\:1094.txt 
stat=$(echo $?)
if [ $stat == 1 ]; then
	cat prod_xrdcmsglobal01.cern.ch:1094.txt prod_xrdcmsglobal02.cern.ch:1094.txt >> $FEDINFO/in/prod.txt	
else
	cp $FEDINFO/in/prod_xrdcmsglobal01.cern.ch\:1094.txt $FEDINFO/in/prod.txt
fi	


exit 0;
