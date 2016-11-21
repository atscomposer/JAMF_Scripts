#!/bin/sh

lpstat -p | cut -d' ' -f2 | grep PAS-DCW-01 | xargs -I{} lpadmin -x {}

jamf recon
