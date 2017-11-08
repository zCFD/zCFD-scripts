@::!/dos/rocks
@echo off
goto :init

:header
    echo Start remote jupyter notebook
    echo.
    goto :eof

:usage
    echo USAGE:
    echo   %__BAT_NAME% [flags] "required argument" "optional argument" 
    echo.
    echo.  /?, --help           shows this help
    echo.  /s, -s               remote server host name
    echo.  /p, -p               path to zCFD on remote system
    echo.  /d, -d               remote notebook directory
    echo.  /l, -l               local port (default 8888)
    echo.  /v, --verbose        shows detailed output
    goto :eof

:version
    if "%~1"=="full" call :header & goto :eof
    echo %__VERSION%
    goto :eof

:missing_argument
    call :header
    call :usage
    echo.
    echo ****                                   ****
    echo ****    MISSING "REQUIRED ARGUMENT"    ****
    echo ****                                   ****
    echo.
    goto :eof

:init
    set "__NAME=%~n0"
    set "__VERSION=1.0"
    set "__YEAR=2017"

    set "__BAT_FILE=%~0"
    set "__BAT_PATH=%~dp0"
    set "__BAT_NAME=%~nx0"

    set "OptHelp="
    set "OptVersion="
    set "OptVerbose="

    set "UnNamedArgument="
    set "UnNamedOptionalArg="
    set "NamedFlag="
    
    SET "HOST=172.20.1.53"
    SET "LOCAL_PORT=8888"
    SET "ZCFD_HOME=/gpfs/projects/swept2/apps/zCFD"
    SET "NOTEBOOK_DIR=/gpfs/projects/swept2"
    SET "PORT=UNDEFINED"


:parse
    if "%~1"=="" goto :validate

    if /i "%~1"=="/?"         call :header & call :usage "%~2" & goto :end
    if /i "%~1"=="-?"         call :header & call :usage "%~2" & goto :end
    if /i "%~1"=="--help"     call :header & call :usage "%~2" & goto :end

    if /i "%~1"=="/s"         set "HOST=%~2"   & shift & shift & goto :parse
    if /i "%~1"=="-s"         set "HOST=%~2"   & shift & shift & goto :parse
    
    if /i "%~1"=="/p"         set "ZCFD_HOME=%~2"   & shift & shift & goto :parse
    if /i "%~1"=="-p"         set "ZCFD_HOME=%~2"   & shift & shift & goto :parse
    
    if /i "%~1"=="/d"         set "NOTEBOOK_DIR=%~2"   & shift & shift & goto :parse
    if /i "%~1"=="-d"         set "NOTEBOOK_DIR=%~2"   & shift & shift & goto :parse
    
    if /i "%~1"=="/l"         set "LOCAL_PORT=%~2"   & shift & shift & goto :parse
    if /i "%~1"=="-l"         set "LOCAL_PORT=%~2"   & shift & shift & goto :parse

    if not defined UnNamedArgument     set "UnNamedArgument=%~1"     & shift & goto :parse
    if not defined UnNamedOptionalArg  set "UnNamedOptionalArg=%~1"  & shift & goto :parse

    shift
    goto :parse

:validate
    if not defined HOST call :missing_argument & goto :end
    if not defined ZCFD_HOME call :missing_argument & goto :end
    if not defined NOTEBOOK_DIR call :missing_argument & goto :end

:main
    REM get unused remote port
    plink.exe %HOST% "python -c 'import socket; s=socket.socket(); s.bind((\"\", 0)); print(s.getsockname()[1]); s.close()'" > port.txt
    set /p PORT= < port.txt
    del port.txt
        
    REM start web browser
    echo "Access your notebook server at"
    echo "http://localhost:%LOCAL_PORT%/"
    
    start http://localhost:%LOCAL_PORT%
    
    REM start remote notebook server
    plink.exe -L %LOCAL_PORT%:localhost:%PORT%  %HOST% "%ZCFD_HOME%/bin/start_notebook -p %PORT% -d %NOTEBOOK_DIR%"

:end
    call :cleanup
    exit /B

:cleanup
    REM The cleanup function is only really necessary if you
    REM are _not_ using SETLOCAL.
    set "__NAME="
    set "__VERSION="
    set "__YEAR="

    set "__BAT_FILE="
    set "__BAT_PATH="
    set "__BAT_NAME="

    set "OptHelp="
    set "OptVersion="
    set "OptVerbose="

    set "UnNamedArgument="
    set "UnNamedArgument2="
    set "NamedFlag="
    
    SET "HOST="
    SET "LOCAL_PORT="
    SET "ZCFD_HOME="
    SET "NOTEBOOK_DIR="
    SET "PORT="

    goto :eof



