#!/bin/bash
/opt/devkitpro/devkitARM/bin/arm-none-eabi-as -o 1k.elf ./1k.S
/opt/devkitpro/devkitARM/bin/arm-none-eabi-as -o intro.elf ./intro.S
/opt/devkitpro/devkitARM/bin/arm-none-eabi-objcopy -O binary ./intro.elf ./intro.gba
dd bs=1 count=192 if=1k.gba of=header.bin
/opt/devkitpro/devkitARM/bin/arm-none-eabi-objcopy -O binary ./1k.elf ./1k.gba
#gbafix ./1k.gba
#DB
