@echo off

set path=%path%;..\bin\
set CC65_HOME=..\

c:\cc65\bin\ca65 main.s --cpu 6502x
c:\cc65\bin\ld65 -C config\layout.cfg -o "snek.nes" main.o

del *.o

move /Y "snek.*" build\

"build\snek.nes"