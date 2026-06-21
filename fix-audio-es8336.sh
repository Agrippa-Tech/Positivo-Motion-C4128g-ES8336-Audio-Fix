#!/bin/bash

# ES8336 audio fix for Positivo Motion C4128G-14-AX
# Linux Mint 21.3 XFCE

sleep 3

amixer -c 0 set Speaker on
amixer -c 0 set Headphone on
amixer -c 0 set DAC 191
amixer -c 0 set "PGA1.0 1 Master" 32
amixer -c 0 set "PGA5.0 5 Master" 32
amixer -c 0 set "PGA6.0 6 Master" 32
amixer -c 0 set "PGA7.0 7 Master" 32
