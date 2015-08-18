# FederationInfo

Cron:
	Cronjob is done via "create-fedfiles.sh" script. From that script, we are calling "create_allow-list.sh" and "create_fedmaps.py" 

create_allow-list.sh:
	Input : Redirector names -> cms-xrd-global.cern.ch:1094 and cms-xrd-transit.cern.ch:1094 
	Purpose : Query gloabal redirectors above and get the sites and regional redirectors who are subscribed to these global redirectors. 
	Output : Allow list of both US and EU regions are produced. 
