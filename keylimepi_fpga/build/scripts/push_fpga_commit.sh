#!/bin/bash

shopt -s expand_aliases
source ~/.bashrc

echo "Saving the project"
vivado -mode batch -source save_project.tcl
# sleep 120
git add keylimepi_fpga.tcl

# Clean out all stale vivado log files
rm -rfv vivado*

echo "What is your commit message?:"
read message

git commit -m "$message"
git push
