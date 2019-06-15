#!/bin/sh
echo CLEAR TAB | rp write tabs
echo TITLE TAB $1 | rp write tabs
./song.pl < $1 | rp write tabs
