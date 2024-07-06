#!/bin/bash
haxelib run lime build cpp && cd export/release/linux/bin && ./HorizonEngine --verbose && cd ../../../..