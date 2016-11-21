#!/bin/bash

CERTNAME="hq-dcw-01"

## Default result. Gets changed to "Yes" if the Root CA is found
result="No"

while read cert_entry; do
    if [ "$cert_entry" == "$CERTNAME" ]; then
        result="Yes"
    fi
done < <(security find-certificate -a /Library/Keychains/System.keychain | awk -F'"' '/alis/{print $4}')

echo "<result>$result</result>"