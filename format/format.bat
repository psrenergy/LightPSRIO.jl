@echo off

SET BASEPATH=%~dp0

CALL julia +1.12.2 --project=%BASEPATH% %BASEPATH%\format.jl