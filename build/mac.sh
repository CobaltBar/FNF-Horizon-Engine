#!/bin/bash
haxelib run lime build cpp && cd export/release/mac/bin && ./HorizonEngine --verbose && cd ../../../..