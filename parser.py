try: import xml.etree.ElementTree as ET
except ImportError: from elementtree import ElementTree as ET
try: import json
except ImportError: import simplejson as json
import urllib2, httplib, os

# global vars: prod, trans : we create these text files, see run.py
#              cmsTopology : static text from dashboard team,
#              sites       : from BDII
#              output      : {"prod" : [...], "trans" : [...], "nowhere" : [...]}

output = {"prod" : [], "trans" : [], "nowhere" : []}

def getDataFromURL(url, header = {}):
    request = urllib2.Request(url, headers=header)
    urlObj  = urllib2.urlopen(request)
    data    = urlObj.read()
    return data

def getSites():
    XML   = getDataFromURL('http://dashb-cms-vo-feed.cern.ch/dashboard/request.py/cmssitemapbdii')
    XML   = ET.fromstring(XML)
    sites = XML.findall('atp_site')
    ret   = {}
    for site in sites:
        groups   = site.findall('group')
        siteName = None
        for i in groups:
            if i.attrib['type'] == 'CMS_Site':
                siteName = groups[1].attrib['name']
                break
        if not siteName: 
            continue
        services = site.findall('service')
        ret[siteName] = {}
        ret[siteName]['hosts'] = []
        ret[siteName]['name']  = site.attrib['name']
        for service in services:
            serviceName = service.attrib['hostname']
            ret[siteName]['hosts'].append(serviceName)
    return ret

def parseHN(data):
    parsedHNs = []
    for line in data.split('\n'):
        if not len(line): continue
        if ':' in line: line = line[:line.find(':')]
        parsedHNs.append(line)
    return parsedHNs

# read cms topology json file and parse it
with open('input/cms_topology.json') as f: cmsTopology = f.read()
cmsTopology = json.loads(cmsTopology)
def hostname2SiteName(hostname):
    ret = None
    for hn in cmsTopology.keys():
        if hn in hostname: return cmsTopology[hn]['SiteName']
    return ret

# to convert site names into CMS site names
sites = getSites()
def siteName2CMSSiteName(name):
    ret = None
    for cmsSite in sites.keys():
        if sites[cmsSite]['name'] == name: return cmsSite
    return ret

if __name__ == "__main__":
    # get hostnames
    hostnames = {}
    with open('input/prod.txt') as f:  hostnames['prod']  = parseHN(f.read())
    with open('input/trans.txt') as f: hostnames['trans'] = parseHN(f.read())

    # find CMS site name of prod sites
    for federation in ['prod', 'trans']:
        for i in hostnames[federation]:
            cmsSiteName = siteName2CMSSiteName(hostname2SiteName(i))
            if cmsSiteName and not cmsSiteName in output[federation]:
                output[federation].append(cmsSiteName)

    # special case for nowhere sites: if a site is not placed in both
    # federations, move it into "nowhere" array
    for cmsSite in sites.keys():
        if not cmsSite in output['prod'] and not cmsSite in output['trans']:
            output["nowhere"].append(cmsSite)

    with open('federations.json', 'w') as f:
        f.write(json.dumps(output, indent = 1))