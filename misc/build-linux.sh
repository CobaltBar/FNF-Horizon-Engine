#!/bin/bash
lime build cpp -debug && cd export/debug/linux/bin && ./HorizonEngine --verbose && cd ../../../..