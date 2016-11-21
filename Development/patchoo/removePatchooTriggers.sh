#!/bin/bash
#

every120=/Library/LaunchDaemons/com.github.patchoo-trigger-every120.plist
patchoo=/Library/LaunchDaemons/com.github.patchoo-trigger-patchoo.plist

if [ -f $patchoo ]; then
	rm $patchoo
fi
if [ -f $every120 ]; then
 	rm $every120
fi	
