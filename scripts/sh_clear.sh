#!/bin/bash
# Clears the spray can 1
#
# apt-get install liblo-tools
OSC_SEND_PORT=8888
LAYER=0
oscsend localhost ${OSC_SEND_PORT} /clear i ${LAYER}

