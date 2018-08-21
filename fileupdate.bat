call "%TEMP%\sakuraupdate\_setenv.bat"

set srcfile=%srcfolder%\%targetfile%
set newfile=%targetfolder%\%targetfile%
set oldfile=%targetfolder%\%targetfile%.old

@echo srcfolder   =%srcfolder%
@echo targetfolder=%targetfolder%
@echo targetfile  =%targetfile%

if "%targetfolder%"=="" goto :err

@timeout /t 3
if "%targetfile%"=="sakura.exe" taskkill /im %targetfile%
@if "%targetfile%"=="sakura.exe" @timeout /t 3

del "%oldfile%"
ren "%newfile%" %targetfile%.old
@if exist "%newfile%" goto :err
copy /y "%srcfile%" "%newfile%"
@echo %newfile%の差し替えに成功しました。
@timeout /t 3
goto :end
:err
@echo %newfile%の差し替えに失敗しました。
@timeout /t 5
:end
