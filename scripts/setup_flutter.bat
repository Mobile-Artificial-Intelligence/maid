@echo off

:: Get the current directory of the script
set "script_dir=%~dp0"

:: Remove trailing backslash
set "flutter_path=%script_dir:~0,-1%\..\packages\flutter\bin"

:: Add Flutter to the PATH
set PATH=%flutter_path%;%PATH%

echo Flutter path set to %flutter_path%
