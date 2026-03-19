@echo off
setlocal enabledelayedexpansion

if "%DEPLOYMENT_SOURCE%"=="" set DEPLOYMENT_SOURCE=%~dp0
if "%DEPLOYMENT_TARGET%"=="" set DEPLOYMENT_TARGET=%~dp0wwwroot

set "PUBLISH_DIR=%DEPLOYMENT_SOURCE%\_functions_publish"

echo Building Azure Functions project from %DEPLOYMENT_SOURCE%...
dotnet publish "%DEPLOYMENT_SOURCE%\FakeAlwaysOn.csproj" -c Release -o "%PUBLISH_DIR%"
if errorlevel 1 goto error

echo Copying published output to %DEPLOYMENT_TARGET%...
if not exist "%DEPLOYMENT_TARGET%" mkdir "%DEPLOYMENT_TARGET%"
xcopy "%PUBLISH_DIR%\*" "%DEPLOYMENT_TARGET%\" /E /Y /I >nul
if errorlevel 1 goto error

echo Function deployment completed successfully.
exit /b 0

:error
echo Function deployment failed with exit code %ERRORLEVEL%.
exit /b %ERRORLEVEL%
