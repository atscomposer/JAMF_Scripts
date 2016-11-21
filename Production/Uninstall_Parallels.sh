#!/bin/bash

if [ -d /Library/Parallels/pma_agent.app/ ]; then
	/Library/Parallels/pma_agent.app/Contents/MacOS/pma_agent_uninstaller.app/Contents/Resources/UninstallAgentScript.sh
else
exit 0
fi
