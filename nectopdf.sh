#!/bin/bash

# NEC to searchable PDF script
# Grab the NEC for free. Still requires script to stitch into a single document.

PAGES='881'
URL='http://www.nfpa.org/NFPA/Custom%20Pages/NFPARequestHandler.ashx?handler=Access&amp;pg='
SAVE='nec'
HOST='www.nfpa.org'
AGENT='Your Face'
COOKIE='Extract from browser'
CURL='/usr/local/Cellar/curl/7.55.1/bin/curl'

for ((i=821; i<=$PAGES; i++)); do
	torify $CURL "$URL$i" -o "$SAVE/$i.jpg" -H "Host: $HOST" -H "User-Agent: $AGENT" -H "Cookie: $COOKIE"-H "Connection: keep-alive" | tee debug.log
	echo "DONE WITH PAGE $i"
done

say "I am done downloading the National Electric Code, sir. Would you like another mamosa?"
echo "DONE DOWNLOADING THE NATIONAL ELECTRIC CODE"

###Script to convert to OCR and merge to one file here
