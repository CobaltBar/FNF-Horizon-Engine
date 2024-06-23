#!/bin/bash
lime build cpp -debug && cd export/release/linux/bin && ./HorizonEngine --verbose && cd ../../../..