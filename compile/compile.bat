@echo off

SET BASEPATH=%~dp0

CALL "%JULIA_1120%" --project=%BASEPATH% %BASEPATH%\compile.jl %*
