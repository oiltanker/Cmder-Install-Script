@echo off
set cr=%~dp0
set out=%cr%out

for /F "tokens=*" %%g IN (
	'REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path'
) do (set curPath=%%g)
echo %curPath% | grep -Eo "([^ ]+ {4}){2}" > %out%
for /F "tokens=*" %%g IN ('cat %out%') do (set cpCut=%%g)
echo %curPath% | sed -e "s/^%cpCut%//" > %out%
for /F "tokens=*" %%g IN ('cat %out%') do (set curPath=%%g)
set curPath=%curPath:~0,-1%
del /f %out%

echo Creating context menu and variable registry intaller ...

set crp=%cr:\=\\%
for /F "tokens=*" %%g IN ('where cmd') do (SET cmdp=%%g)
set cmdp=%cmdp:\=\\%
set ccr=%cr:~0,-1%
set ccr=%ccr:\=\\%
set curPathP=%curPath:\=\\%

echo Creating cmd-cmder script ...

set ccs=%cr%\cmd-cmder.bat

echo @echo off > %ccs%
echo cmd /k "%cr%vendor\init.bat" >> %ccs%

echo Creating context menu registry intaller ...

set reg_file="%cr%CmderCM.reg"

echo Windows Registry Editor Version 5.00 > %reg_file%
echo. >> %reg_file%
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\Cmder] >> %reg_file%
echo @="Open Cmder Here" >> %reg_file%
echo "Icon"="\"%crp%\\icons\\cmder.ico\",0" >> %reg_file%
echo.  >> %reg_file%
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\Cmder\command] >> %reg_file%
echo @="\"%crp%\\Cmder.exe\" /start \"%%v\"" >> %reg_file%
echo.  >> %reg_file%
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\cmd-cmd] >> %reg_file%
echo @="Open Terminal Here" >> %reg_file%
echo "Icon"="\"%cmdp%\"" >> %reg_file%
echo.  >> %reg_file%
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\cmd-cmd\command] >> %reg_file%
echo @="\"%cmdp%\"" >> %reg_file%
echo.  >> %reg_file%
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\cmd-cmder] >> %reg_file%
echo @="Open Cmder terminal Here" >> %reg_file%
echo "Icon"="\"%cmdp%\"" >> %reg_file%
echo.  >> %reg_file%
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\cmd-cmder\command] >> %reg_file%
echo @="cmd /k \"%crp%\\vendor\\init.bat\"" >> %reg_file%
echo. >> %reg_file%
echo [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment] >> %reg_file%
echo "CMDER_ROOT"="%ccr%" >> %reg_file%
echo %curPath% | findstr /C:"C:\Cmder" > nul
if %errorLevel% EQU 0 (
    echo -- Path variable already set.
) else (
    echo "Path"="%curPathP%%ccr%;" >> %reg_file%
)

echo Running registry intaller ...

regedit.exe /S %reg_file%

echo Cleanup ...

del /f %reg_file%

echo.
pause