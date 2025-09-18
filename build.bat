@echo off
chcp 65001 >nul
setlocal

mkdir fasm
curl -o fasm.zip https://flatassembler.net/fasmw17332.zip

tar -xf fasm.zip -C fasm
rem fasm.zip

fasm\fasm.exe korsakov.asm -d WINDOWS=1

endlocal
