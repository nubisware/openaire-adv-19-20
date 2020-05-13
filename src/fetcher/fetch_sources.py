#!/bin/python
import requests
import time
import re
from threading import Thread

class Pusher (Thread):
    def __init__(self, url, data):
        Thread.__init__(self)
        self.url = url
        self.data = data
    def run(self):
        start = time.time()
        resp2 = requests.post(self.url, data=self.data, headers={'Content-Type': 'application/xml'})
        print("pushed to " + url + " in " + str(elapsed(start)))

def elapsed(s):
    return round((time.time() - s) * 1000) / 1000

sources = [
    {"name" : "MediaTUM", "count" :  33998, "url" : "https://mediatum.ub.tum.de/oai/oai,open_access"},
    {"name" : "Science and Religion Dialogue Prints", "count" :  299, "url" : "http://scireprints.lu.lv/cgi/oai2"},
    {"name" : "E-Prints Complutense", "count" :  37251, "url" : "http://eprints.ucm.es/cgi/oai2"}
]

globalstart = time.time()
index = 1
source = "source" + str(index)
harvesturl = 'http://localhost:8984/harvest/' + source
page = 0
final = False
qparams = {'verb':"ListRecords", "metadataPrefix" : "oai_dc"}
while not final:
    page += 1
    
    #fetching from source
    start = time.time()
    resp = requests.get(sources[index]["url"], params = qparams)
    print("fetched page " + str(page) + " in " + str(elapsed(start)))
    
    #posting to harvesting service
    url = harvesturl + "/" + str(page)
    (Pusher(url, resp.content)).start()
    
    #checking for continuation
    #result = resp2.json()
    #if result["continuation"] != None:
    #    qparams = {'verb':"ListRecords", "resumptionToken" : result["continuation"]}
    #else:
    #    final = True
    tok = re.findall("<[.]*resumptionToken[^>]*>([^<]+)</", resp.text)
    if len(tok) == 1:
        qparams = {'verb':"ListRecords", "resumptionToken" : tok[0]}
    else: final = True
    

print("Done in total" + str(elapsed(globalstart)))
