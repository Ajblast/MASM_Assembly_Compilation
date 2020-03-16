@echo off

::*****************************************************************************************
::	File Name:				CreateProject
::	Programmer:				Austin Kincer
::	Date Created:			3/14/2020
::	Date Last Modified:		3/15/2020
::	Purpose:				Create a project file structure
::*****************************************************************************************

rem Get the script drive letter
rem Get the script path
rem Get the script absolute path

SETLOCAl EnableDelayedExpansion EnableExtensions
set _SCRIPT_DRIVE=%~d0
set _SCRIPT_PATH=%~p0
set _SCRIPT_ABS=%~dp0

rem Should an include directory be included
set _CREATE_INCLUDE=FALSE
rem Should an asm be created
set _CREATE_ASM=TRUE

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
		IF !switchVal!==i (			rem Create an include folder
			set _CREATE_INCLUDE=TRUE
			GOTO:endingLoop
		)
		IF !switchVal!==e (			rem Do not create an asm
			set _CREATE_ASM=FALSE
			GOTO:endingLoop
		)
		IF !switchVal!==c (			rem Create a .asm with the following name
			rem Shift the parameters
			SHIFT
			
			rem Access second. Technically, Shift happens after the if statement
			set var=%~2
			IF "!var!"=="" (		rem Check if the next parameter actually exists
				ECHO ***WARNING*** /c given without file name
				GOTO:eof
			)
			
			set _FILE_NAME=!var!
			GOTO:endingLoop
		)
		
		rem This was not a valid switch
		ECHO:Unknown Switch Value: !switchVal!
		GOTO:echoERROR		
	)	
	
	rem Current parameter is not a switch	
	
	rem If the PROJECT NAME hasn't been set yet
	IF NOT DEFINED _PROJECT_NAME (	
		set _PROJECT_NAME=%var%
		set _PROJECT_PATH=%_SCRIPT_ABS%Projects\%var%\
		
		IF NOT DEFINED _FILE_NAME (
			set _FILE_NAME=%var%
		)
		
		GOTO:endingLoop
	)
	
	:endingLoop
	SHIFT
	GOTO:parameterLoop
:endParameterLoop


:errorChecking
IF NOT DEFINED _PROJECT_NAME (
	ECHO ***ERROR*** Project Name was not set
	GOTO:echoERROR
)


:directoryCreation
rem Make a directory for the project name if it doesn't exist
IF NOT EXIST "%_PROJECT_PATH%" mkdir "%_PROJECT_PATH%"
IF NOT EXIST "%_PROJECT_PATH%bin" mkdir "%_PROJECT_PATH%bin"
IF NOT EXIST "%_PROJECT_PATH%bin-int" mkdir "%_PROJECT_PATH%bin-int"

IF %_CREATE_INCLUDE%==TRUE ( 	rem Should an include directory be created
	rem Make a directory for the include dir if it doesn't exist
	IF NOT EXIST "%_PROJECT_PATH%include" mkdir "%_PROJECT_PATH%include"
)

:asmCreation
IF %_CREATE_ASM%==TRUE (	rem Create the asm
	call AddASM %_PROJECT_NAME% %_FILE_NAME%
)

GOTO:eof
:echoHELP
	ECHO Create a project folder structure
	ECHO.
	ECHO CreateProject projectName [/i] [/e ^| {/c fileName}]
	ECHO.
	ECHO 	projectName				Name of the project.
	ECHO 	[/i]					Create an include folder
	ECHO 	[/e ^| {/c fileName}]		
	ECHO 		/e				Indicates to not create a .asm file
	ECHO 		/c				Create a .asm with file name
	ECHO 		fileName			Name of the file.
	GOTO:eof
	
:echoERROR
	ECHO Try CreateProject /?
	GOTO:eof

