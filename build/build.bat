@echo off
lime build cpp && cd export\release\windows\bin && HorizonEngine.exe --verbose && cd ../../../..