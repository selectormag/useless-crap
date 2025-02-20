#!/bin/bash

# Salesforce AEM Vulnerability Mitigator

# Disables the SalesForce MCM Bundle en masse

PASS=$(cat pass.secret)

HOST="${1}"

if [[ -z "${2}" ]]; then
	# Port was not specified. Assuming 443
	PORT=443
else
	# Port specified
	PORT="${2}"
fi

AUTHTEST=$(curl -s -I -k -u admin:"${PASS}" https://"${HOST}":"${PORT}"/system/console/bundles | egrep "200|302")

if [[ -z "${AUTHTEST}" ]]; then
	echo "ERROR: Authentication failed. Check your credentials and verify the host and port are correct."
	exit 1
else
	echo "INFO: Authentication successful. Attempting to disable bundle..."
fi

RESULT=$(curl -s -k -u admin:"${PASS}" https://"${HOST}":"${PORT}"/system/console/bundles/com.day.cq.mcm.cq-mcm-salesforce -F action=stop | grep false)

if [[ -z "${RESULT}" ]]; then
	# Not the expected result. There is likely a problem
	echo "ERROR: Didn't get expected result. Please check to ensure bundle was disabled. OUTPUT: ${RESULT}"
	exit 1
else
	# Output as expected
	echo "INFO: Bundle successfully disabled. Checking MCM page to verify information is no longer being leaked..."
fi

# Testing page to validate it's not outputting anything dangerous anymore

ISDANGER=$(curl -sk -u admin:"${PASS}" "https://${HOST}:${PORT}/libs/mcm/salesforce/customer.html%3b%0aa.css?checkType=authorize&authorization_url=http://169.254.169.254/latest/meta-data/iam/security-credentials/InstanceRole&customer_key=zzzz&customer_secret=zzzz&redirect_uri=xxxx&code=e" | egrep -i "AccessKey|SecretAccessKey")

if [[ -n "${ISDANGER}" ]]; then
	# Privileged info still on page. Not good.
	echo "ERROR: There is still information being leaked at https://${HOST}:${PORT}/libs/mcm/salesforce/customer.html%3b%0aa.css?checkType=authorize&authorization_url=http://169.254.169.254/latest/meta-data/iam/security-credentials/InstanceRole&customer_key=zzzz&customer_secret=zzzz&redirect_uri=xxxx&code=e . Please manually check this."
else
	echo "INFO: Information no longer being leaked. The mitigation was successful."
fi
