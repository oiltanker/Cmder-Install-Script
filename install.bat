@echo off

net session >nul 2>&1
if %errorLevel% EQU 0 (
    echo Running with administrator privileges...
) else (
    echo Failure: Administrator privileges are required.
	goto error
)

set cr=%~dp0
echo Checking direcory ...

set cmderExe="%cr%Cmder.exe"
set initBat="%cr%vendor\init.bat"

if exist %cmderExe% (
    if exist %initBat% (
		echo -- Success: is Cmder direcory
		goto install
	) else (
		goto dep_fail
	)
) else (
    goto dep_fail
)
:dep_fail
echo -- Failure: Script must be run in Cmder directory.
goto error

:install
echo Running install ...

set CMDER_ROOT=%cr%
start cmd /k "%CMDER_ROOT%\vendor\init.bat cd %cr% && install-cmder.bat && exit"
exit

:error
echo.
pause