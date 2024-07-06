@echo off
haxelib run lime build cpp && cd export\release\windows\bin && HorizonEngine.exe --verbose && cd ../../../..