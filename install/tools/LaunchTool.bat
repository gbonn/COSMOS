@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

SET RUBYEXE=%1
SET TOOL=%~dp0%2

IF NOT EXIST !TOOL! (
  echo !TOOL! does not exist
  pause
  exit /b
)

IF NOT EXIST %~dp0launch_tool.rb (
  echo %~dp0launch_tool.rb does not exist
  pause
  exit /b
)

:: Get just the parameters for the tool
shift
shift
set PARAMS=%1
:loop
shift
if [%1]==[] goto afterloop
set PARAMS=!PARAMS! %1
goto loop
:afterloop

:: First look two directories up
SET "DESTINATION_DIR=%~dp0..\..\"
IF NOT EXIST "!DESTINATION_DIR!Vendor\Ruby" (
  :: Then check COSMOS_DIR environment variable
  IF NOT "!COSMOS_DIR!"=="" (
    SET "DESTINATION_DIR=!COSMOS_DIR!\"
  )
)

IF EXIST "!DESTINATION_DIR!Vendor\Ruby" (
  :: Set environmental variables
  for /f "delims=" %%a in ('dir "!DESTINATION_DIR!Vendor\Ruby\lib\ruby\gems\2*" /on /ad /b') do set RUBY_ABI=%%a
  SET "GEM_HOME=!DESTINATION_DIR!Vendor\Ruby\lib\ruby\gems\!RUBY_ABI!"
  SET "GEM_PATH=!GEM_HOME!"
  SET "GEMRC=!DESTINATION_DIR!Vendor\Ruby\lib\ruby\gems\etc\gemrc"

  :: Prepend embedded bin to PATH so we prefer those binaries
  SET "RI_DEVKIT=!DESTINATION_DIR!Vendor\Devkit\"
  SET "PATH=!DESTINATION_DIR!Vendor\Ruby\bin;!RI_DEVKIT!bin;!RI_DEVKIT!mingw\bin;!DESTINATION_DIR!Vendor\wkhtmltopdf;!PATH!"

  :: Remove RUBYOPT and RUBYLIB, which can cause serious problems.
  SET RUBYOPT=
  SET RUBYLIB=

  :: Run tool using Installer Ruby
  ECHO Starting tool using installer ruby in !DESTINATION_DIR!
  START "COSMOS" "!DESTINATION_DIR!Vendor\Ruby\bin\!RUBYEXE!" "!TOOL!" !PARAMS!
) else (
  :: Use System Ruby and Environment
  ECHO Starting tool using system ruby and environment
  START "COSMOS" "!RUBYEXE!" "!TOOL!" !PARAMS!
)

ENDLOCAL