#!/bin/sh
result=`/usr/sbin/firmwarepasswd -check`

if [[ "$result" == "Password Enabled: Yes" ]]; then
echo "<result>Set</result>"
else
echo "<result>Not Set</result>"
fi