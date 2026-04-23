#!/bin/bash

# 1. Forza l'unmute su tutti i controlli della scheda 0 'ES8336'
for control in "Speaker" "Headphone" "DAC" "Output Mixer" "Master"; do
    amixer -c 0 sset "$control" unmute 100% > /dev/null 2>&1
done

# 2. Forza PipeWire a usare l'uscita analogica 'ES8336'
NODE_ID=$(wpctl status | grep -i "ES8336" | grep -v "HDMI" | head -n 1 | sed 's/[^0-9]*\([0-9]\+\).*/\1/')

if [ ! -z "$NODE_ID" ]; then
    wpctl set-default $NODE_ID
fi
