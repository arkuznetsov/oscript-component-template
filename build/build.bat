@ECHO OFF

echo %~dp0
@chcp 65001

SET OSCRIPT_COMPONENT_NAME=oscript-component

IF NOT EXIST "%~dp0../tools/nuget.exe" (
    @"C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe" curl -o "%~dp0../tools/nuget.exe" https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
)

@"%~dp0../tools/nuget.exe" restore %~dp0../src

@dotnet restore %~dp0../src
@dotnet msbuild %~dp0../src -property:Configuration=Release

@rd /S /Q "%~dp0bin" 
@mkdir "%~dp0bin"
@xcopy %~dp0..\src\%OSCRIPT_COMPONENT_NAME%\bin\Release\net452\*.dll %~dp0bin\
@xcopy %~dp0..\src\%OSCRIPT_COMPONENT_NAME%\bin\Release\net452\*.xml %~dp0bin\
@del /F /Q "%~dp0bin\OneScript*.*" "%~dp0bin\ScriptEngine*.*" "%~dp0bin\DotNetZip*.*" "%~dp0bin\Newtonsoft*.*"

@"C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe" curl -o "%~dp0OneScriptDocumenter.zip" https://github.com/dmpas/OneScriptDocumenter/releases/download/1.0.14/documenter.zip
@"C:\Program Files\7-Zip\7z.exe" x -o%~dp0OneScriptDocumenter -y %~dp0OneScriptDocumenter.zip
@del /F /Q "%~dp0OneScriptDocumenter*.*"

@%~dp0OneScriptDocumenter\OneScriptDocumenter.exe json %~dp0bin\syntaxHelp.json %~dp0..\src\%OSCRIPT_COMPONENT_NAME%\bin\Release\net452\%OSCRIPT_COMPONENT_NAME%.dll

@rd /S /Q "%~dp0OneScriptDocumenter"

opm build -o %~dp0 %~dp0
@exit /b %ERRORLEVEL%