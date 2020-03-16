@echo off

::*****************************************************************************************
::	File Name:				AddASM
::	Programmer:				Austin Kincer
::	Date Created:			3/14/2020
::	Date Last Modified:		3/15/2020
::	Purpose:				Add assembly files in a project or dynamic file structure
::*****************************************************************************************

rem enable delayed expansion
SETLOCAl EnableDelayedExpansion EnableExtensions

rem Batch File Script Paths
set _SCRIPT_DRIVE=%~d0
set _SCRIPT_PATH=%~p0
set _SCRIPT_ABS=%~dp0


rem Possible File types DEFAULT, EMPTY
set _FILE_TYPE=DEFAULT

rem Should we fill in file details (Creation Date, etc)
set _FILL_DETAILS=FALSE

:parameterLoop
	set var=%~1

	IF "%var%"=="" GOTO:endParameterLoop

	rem Check switches
	IF "%var:~0,1%"=="/" (			rem this is a switch
	
		rem Get a copy of the switch without the /
		set switchVal=!var:~1!
								
		IF !switchVal!==? (			rem This means to display the help
			GOTO:echoHELP
		)		
		IF !switchVal!==d (			rem This mean the file should be default
			set _FILE_TYPE=DEFAULT
			GOTO:endingLoop
		)
		IF !switchVal!==e (			rem This mean the file should be empty
			set _FILE_TYPE=EMPTY
			GOTO:endingLoop
		)		
		IF !switchVal!==f (			rem This means to fill in file details
			set _FILL_DETAILS=TRUE
			ECHO ***WARNING*** Fill feature not implemented
			GOTO:eof
			GOTO:endingLoop
		)
		
		rem This was not a valid switch
		ECHO Unknown Switch Value: !switchVal!
		GOTO:echoERROR		
	)	
	
	rem Current parameter is not a switch	
	
	rem If the PROJECT NAME hasn't been set yet
	IF NOT DEFINED _PROJECT_NAME (	
		set _PROJECT_NAME=%var%
		GOTO:endingLoop
	)
	
	rem If the FILE NAME hasn't been set yet
	IF NOT DEFINED _FILE_NAME (
		set _FILE_NAME=%var%
		GOTO:endingLoop
	)
	
	:endingLoop
	SHIFT
	GOTO:parameterLoop
:endParameterLoop

:errorChecking
	rem Error Checking
	IF NOT DEFINED _PROJECT_NAME (
		ECHO ***ERROR*** ProjectName was not set
		GOTO:echoERROR
	)
	IF NOT DEFINED _FILE_NAME (
		rem IF a FILE NAME was not given, just use the proejct name
		set _FILE_NAME=%_PROJECT_NAME%
	)

	rem Set the project's path
	set _PROJECT_PATH=%_SCRIPT_ABS%Projects\%_PROJECT_NAME%\

	rem Make sure the project exists
	IF NOT EXIST "%_PROJECT_PATH%" (
		ECHO "ProjectPath ("%_PROJECT_PATH%") does not exist. Not creating file."
		GOTO:eof
	)

	rem Check if the file already exists
	IF EXIST "%_PROJECT_PATH%%_FILE_NAME%.asm" (
		ECHO ***WARNING*** File already exists: "%_PROJECT_PATH%%_FILE_NAME%"
		GOTO:eof
	)

:fileCopy
	rem To add extra file types, just duplicate the following if statement and add its
	rem Corresponding switch

	rem DEFAULT file type
	IF %_FILE_TYPE%==DEFAULT (
		IF NOT EXIST "%_SCRIPT_ABS%Templates\DefaultTemplate" (
			ECHO ***WARNING*** Default template does not exist in "%_SCRIPT_ABS%Templates"
			GOTO:eof
		)
		
		rem Copy ProgramTemplate to the directory and rename it to _FILE_NAME.asm
		call copy "%_SCRIPT_ABS%Templates\DefaultTemplate" "%_PROJECT_PATH%%_FILE_NAME%.asm"
		
		rem Check if the copy was completed
		IF %errorlevel% == 1 (
			ECHO ***WARNING*** Unable to complete copy of DEFUALT template
			GOTO:eof
		)
		
		ECHO 	Added "%_PROJECT_PATH%%_FILE_NAME%.asm"
		
		rem Skip checking other file types
		GOTO:endFileCopy
	)

	rem EMPTY file type
	IF %_FILE_TYPE%==EMPTY (
		IF NOT EXIST "%_SCRIPT_ABS%Templates\EmptyTemplate" (
			ECHO ***WARNING*** Default template does not exist in "%_SCRIPT_ABS%Templates"
			GOTO:eof
		)	
		
		rem Copy ProgramTemplate to the directory and rename it to _FILE_NAME.asm
		call copy "%_SCRIPT_ABS%Templates\EmptyTemplate" "%_PROJECT_PATH%%_FILE_NAME%.asm"
		
		rem Check if the copy was completed
		IF %errorlevel% == 1 (
			ECHO ***WARNING*** Unable to complete copy of EMPTY template
			GOTO:eof
		)
		
		ECHO 	Added "%_PROJECT_PATH%%_FILE_NAME%.asm"

		
		rem Skip checking other file types
		GOTO:endFileCopy
	)

:endFileCopy
GOTO:eof

:echoHELP
	ECHO Add a .asm file to a project
	ECHO.
	ECHO AddASM projectName [/d ^| /e] [/f] [fileName]
	ECHO.
	ECHO 	projectName		Name of the project to add the file
	ECHO 	[/d ^| /e]
	ECHO 		/d		Specifies default file template
	ECHO 		/e		Specifies empty file template
	ECHO 	[/f]			Fill .asm with fill values (Create date, Project Name, etc.)
	ECHO 	fileName		Name of the file. Defaults to project name when not present
	GOTO:eof

:echoERROR
	ECHO Try AddASM /?
	GOTO:eof