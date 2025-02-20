#!/bin/bash
# Stupid simple tool to check for changes in whois data, potentially useful for tracking when a domain expires

DOMAIN='example.net'

whois "${DOMAIN}" | grep -iv "Last update of WHOIS" > newwhois
DIFFCHK=$(diff newwhois oldwhois)

if [[ -n "${DIFFCHK}" ]]; then
	echo "NOTICE: The whois result for ${DOMAIN} has changed since the last check."
else
	echo "The whois result for ${DOMAIN} has not changed since the last check."
fi

mv -f newwhois oldwhois

