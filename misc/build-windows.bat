@echo off
lime build cpp -debug && cd export\release\windows\bin && HorizonEngine.exe --verbose && cd ../../../..