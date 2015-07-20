#!/bin/bash

#cd /var/www/html/parser
BASE=/var/www/html/cmsfed-allow-list
FEDINFO=/var/www/html/FederationInfo

xrdmapc --list all xrdcmsglobal02.cern.ch:1094 | grep Man  | awk '{print $3}' > $BASE/tmp_manlist
for i in $(cat $BASE/tmp_manlist);do
	xrdmapc --list all $i > $BASE/tmp_$i	
	cat $BASE/tmp_$i | awk '{if($2=="Man") print $3; else print $2}' | tail -n +2 >> $BASE/tmp_total
done

cat $BASE/tmp_total | cut -d : -f1 | sort -u > $FEDINFO/input/prod.txt 
cat $FEDINFO/input/prod.txt | cut -d : -f1 | awk -F. '{print "cms.allow host " "*."$(NF-1)"."$NF}' | sort -u > $BASE/list_eu.txt
rm $BASE/tmp_*

#cd $FEDINFO
#python parser.py

exit 0;
