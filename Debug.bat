@ECHO off

::*****************************************************************************************
::	File Name:				Debug
::	Programmer:				Austin Kincer
::	Date Created:			3/14/2020
::	Date Last Modified:		3/15/2020
::	Purpose:				Debug executable in a project or dynamic file structure
::*****************************************************************************************

rem Get the script drive letter
rem Get the script path
rem Get the script absolute path

SETLOCAl EnableDelayedExpansion EnableExtensions
set _SCRIPT_DRIVE=%~d0
set _SCRIPT_PATH=%~p0
set _SCRIPT_ABS=%~dp0

set _DEBUG=FALSE

set _EXECUTABLE_PATH=
set _EXECUTABLE=


:parameterLoop
	set var=%~1
	
	IF "%var%"=="" GOTO:endParameterLoop

	rem Check switches
	IF "%var:~0,1%"=="/" (			rem this is a switch	
	
		rem Get a copy of the switch without the /
		set switchVal=%var:~1%
					
					
		IF !switchVal!==? (			rem Display help
			GOTO:echoHELP
		)
		IF !switchVal!==p (			rem Specified pathing
			rem Set the assemble path and output path
			SHIFT
			set _EXECUTABLE=%~n2
			set _EXECUTABLE_PATH=%~2
			GOTO:endingLoop
		)
		IF !switchVal!==d (
			set _DEBUG=TRUE
			GOTO:endingLoop
		)
		
		
		rem This was not a valid switch
		ECHO:Unknown Switch Value: !switchVal!
		GOTO:echoERROR		
	)	
	
	rem Current parameter is not a switch	
	
	rem If the _EXECUTABLE_PATH hasn't been set yet
	rem So set it with the very first non-switch argument (Should be project name)
	IF NOT DEFINED _EXECUTABLE_PATH (
		set _EXECUTABLE_PATH=%_SCRIPT_ABS%Projects\%var%\bin-int\
		
		rem Check if the optional executable name was given
		set nextArg=%~2
		IF "!nextArg!"=="/E" (
			set _EXECUTABLE=!nextArg!
			
			rem Shift down for the executable name
			SHIFT
		) ELSE (
			rem Need to find the executable
			
			rem Get the first executable
			FOR /F "tokens=*" %%g IN ('dir /b "!_EXECUTABLE_PATH!*.exe" 2^>nul ^| findstr /N /R ".*" ^| findstr /R "1:"') DO (
				set tempVar=%%g
				set _EXECUTABLE=!tempVar:~2!
			)			
		)
		
		set _EXECUTABLE_PATH=%_SCRIPT_ABS%Projects\%var%\bin-int\!_EXECUTABLE!
		
		GOTO:endingLoop
	)
	
	:endingLoop
	SHIFT
	GOTO:parameterLoop
:endParameterLoop

:errorChecking
	IF NOT DEFINED _EXECUTABLE_PATH (
		ECHO ***ERROR*** Executable path was not set
		GOTO:echoERROR
	)	
	IF NOT DEFINED _EXECUTABLE (
		ECHO ***ERROR*** Executable name was not set
		GOTO:echoERROR
	)

:debugging
	IF %_DEBUG%==TRUE (
		ECHO.
		ECHO *********DEBUG INFORMATION*********
		ECHO Executable:	%_EXECUTABLE%
		ECHO ExecutablePath:	%_EXECUTABLE_PATH%

		ECHO.	

		ECHO *********DEBUG INFORMATION*********		
	)
		
:debugger
	rem call the assembler
	IF %_DEBUG%==TRUE (
		ECHO.
		ECHO Debugging...
		ECHO.
	)
	
	ECHO.
	
	ECHO Debugger Running...
	
	rem Run the debugger
	"%_SCRIPT_ABS%MASM\windbg.exe" "%_EXECUTABLE_PATH%"
	
	ECHO Debugger Closed
	
GOTO:eof
:echoHELP
	ECHO Debug executable in a project or dynamic file structure
	ECHO.
	ECHO Debug ({/p executablePath} ^| projectName [/E executableName]) [/d]
	ECHO.
	ECHO 	({/p executablePath} ^| projectName [/E executableName])
	ECHO 		/p					Define the path for the executable
	ECHO 		executablePath				Executable path
	ECHO 		projectName				Name of the project
	ECHO 		executableName				Name of the executable
	ECHO 	[/d]						Print all information
	GOTO:eof
	
:echoERROR
	ECHO Try Assemble /?
	GOTO:eof