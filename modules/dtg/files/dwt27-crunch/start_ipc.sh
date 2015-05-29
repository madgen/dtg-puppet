#!/bin/bash

# Exit if ipcluster already running
ps xc | grep -F ipcluster >/dev/null && exit 0

cd /home/dwt27/ipc
source venv/bin/activate
ipcluster start -n 7 >/dev/null 2>&1
echo Started/restarted ipcluster at `date`
