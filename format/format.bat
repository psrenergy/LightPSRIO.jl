@echo off

SET BASEPATH=%~dp0
SET JULIA=1.12.1

CALL juliaup add %JULIA%
CALL julia +%JULIA% --project=%BASEPATH% %BASEPATH%\format.jl