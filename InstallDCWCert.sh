#!/bin/bash

CERT_PATH="/private/var/tmp"
SYSTEM_KEYCHAIN="/Library/Keychains/System.keychain"

/usr/bin/security add-trusted-cert -d -r trustRoot -k ${SYSTEM_KEYCHAIN} ${CERT_PATH}/hq-dcw-01.cer
#rm -f ${CERT_PATH}/hq-dcw-01.cer

exit 0