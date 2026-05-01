#!/bin/bash

# WhoSingsThis Launcher Script
echo "Checking dependencies..."

# Check for PulseAudio utils
if ! command -v parecord &> /dev/null
then
    echo "ERROR: 'pulseaudio-utils' is missing. Please run: sudo apt-get install pulseaudio-utils"
    exit 1
fi

# Check for Chromaprint
if ! command -v fpcalc &> /dev/null
then
    echo "WARNING: 'fpcalc' is missing. Music recognition will be simulated in debug mode."
    echo "To fix: sudo apt-get install libchromaprint-tools"
fi

echo "Launching WhoSingsThis (Linux)..."
./client/build/linux/x64/release/bundle/client
