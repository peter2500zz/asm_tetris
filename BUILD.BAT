@echo off
del TARGET\*.*
rd TARGET
md TARGET
cd TARGET

masm ..\SRC\GRAPHIC\SWITCH.ASM ,,,,
if ERRORLEVEL 1 goto failed

masm ..\SRC\GRAPHIC\UTILS.ASM ,,,,
if ERRORLEVEL 1 goto failed

masm ..\SRC\GAME\PLAYGRND.ASM ,,,,
if ERRORLEVEL 1 goto failed

masm ..\SRC\MAIN.ASM ,,,, /cSWITCH.OBJ,UTILS.OBJ,PLAYGRND.OBJ
if ERRORLEVEL 1 goto failed

link MAIN.OBJ+SWITCH.OBJ+UTILS.OBJ+PLAYGRND.OBJ,TETRIS.EXE,,, 
if ERRORLEVEL 1 goto failed

goto success

:failed
echo.
echo build failed
goto finish

:success
echo build success
choice run it right now?
if ERRORLEVEL 2 goto not_run

TETRIS.EXE
:not_run
echo.
:finish
cd ..
