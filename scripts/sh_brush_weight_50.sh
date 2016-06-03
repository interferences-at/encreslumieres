#!/bin/bash
OSC_SEND_PORT=31340
IDENTIFIER=0
BRUSH_WEIGHT=50
osc-send -p ${OSC_SEND_PORT} /brush/weight ,if ${IDENTIFIER} ${BRUSH_WEIGHT}