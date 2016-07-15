#!/bin/sh

lpstat -p | cut -d' ' -f2 | grep HQ_PRINTSRV | xargs -I{} lpadmin -x {}

jamf recon
