#!/bin/sh

#
# This script should be added in crontab (@reboot rule)
#

# Changement 02/2022
# Branchement d'un AKAI MPK vers une sortie MIDI sur serial

cd /home/pi/DEV/piano-assistant/
git pull
./run_midi_interface.sh &
./run_connect.sh &
./run_controller.sh &
