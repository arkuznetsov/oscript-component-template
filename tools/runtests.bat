@ECHO OFF

echo %~dp0
@chcp 65001

SET OSCRIPT_COMPONENT_NAME=oscript-component

IF NOT EXIST "%~dp0nuget.exe" (
  @"C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe" curl -o "%~dp0nuget.exe" https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
)

@%~dp0nuget.exe restore %~dp0../src
@%~dp0nuget.exe install NUnit.ConsoleRunner -Version 3.6.1 -OutputDirectory %~dp0../tools
@dotnet tool install --global dotnet-coverage
@dotnet restore %~dp0../src
@dotnet build %~dp0../src --configuration Debug
@mkdir "%~dp0../build/reports"
@dotnet-coverage collect -o %~dp0../build/reports/coverage.xml -f xml "%~dp0../tools/NUnit.ConsoleRunner.3.6.1/tools/nunit3-console.exe %~dp0../src/NUnitTests/bin/Debug/net452/NUnitTests.dll --result=%~dp0../build/reports/nunit-result.xml"
rem @rd /S /Q "%~dp0../tools/NUnit.ConsoleRunner.3.6.1"
@exit /b %ERRORLEVEL%