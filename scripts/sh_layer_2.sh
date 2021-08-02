#!/bin/bash
# Sends /layer ,ii
# Move spraycan 1 to layer 2

oscsend osc.udp://localhost:8888 /layer ii 1 2
