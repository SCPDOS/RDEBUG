#!/bin/sh
rdebug:
	nasm rdebug.asm -o ./bin/RDEBUG.COM -f bin -l ./lst/rdebug.lst -O0v
