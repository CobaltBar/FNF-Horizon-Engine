@echo off
lime build cpp -debug && cd export\debug\windows\bin && HorizonEngine.exe --verbose && cd ../../../..