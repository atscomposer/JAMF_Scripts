#!/bin/bash
#

CD=/Library/iRobot/CocoaDialog.app

if [ -d $CD ]; then
	rm -rf $CD
fi
