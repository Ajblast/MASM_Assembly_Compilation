@echo off

::*****************************************************************************************
::	File Name:				Clean
::	Programmer:				Austin Kincer
::	Date Created:			3/14/2020
::	Date Last Modified:		3/15/2020
::	Purpose:				Clean files in a project or dynamic file structure
::*****************************************************************************************

SETLOCAl EnableDelayedExpansion EnableExtensions
set _SCRIPT_DRIVE=%~d0
set _SCRIPT_PATH=%~p0
set _SCRIPT_ABS=%~dp0

set _CLEAN_PATH=
set _PROJECT_NAME=

rem Cleaning paths
set _CLEAN_PATH_LST=
set _CLEAN_PATH_OBJ=
set _CLEAN_PATH_EXE=
set _CLEAN_PATH_ILK=
set _CLEAN_PATH_PDB=

rem Should these items be cleaned
set _CLEAN_LST=TRUE
set _CLEAN_OBJ=TRUE
set _CLEAN_EXE=TRUE
set _CLEAN_ILK=TRUE
set _CLEAN_PDB=TRUE

rem Should all information be displayed
set _DEBUG=FALSE


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
		
		rem Specified cleaning path
		IF !switchVal!==c (
			rem Set the clean path
			SHIFT
			set _CLEAN_PATH=%~2
			
			rem Set the initial cleaning paths
			set _CLEAN_PATH_LST=!_CLEAN_PATH!
			set _CLEAN_PATH_OBJ=!_CLEAN_PATH!
			set _CLEAN_PATH_EXE=!_CLEAN_PATH!
			set _CLEAN_PATH_ILK=!_CLEAN_PATH!
			set _CLEAN_PATH_PDB=!_CLEAN_PATH!

			GOTO:endingLoop
		)
		
		rem Set whether debugging should occur
		IF !switchVal!==d (
			set _DEBUG=TRUE
			GOTO:endingLoop
		)
		
		:specifiedCleaningPaths
			rem Specified .lst cleaning path
			IF !switchVal!==l (
				SHIFT
				set _CLEAN_PATH_LST=%~2
				GOTO:endingLoop
			)
	
			rem Specified .obj cleaning path
			IF !switchVal!==o (
				SHIFT
				set _CLEAN_PATH_OBJ=%~2
				GOTO:endingLoop
			)
	
			rem Specified .exe cleaning path
			IF !switchVal!==e (
				SHIFT
				set _CLEAN_PATH_EXE=%~2
				GOTO:endingLoop
			)
	
			rem Specified .ilk cleaning path
			IF !switchVal!==i (
				SHIFT
				set _CLEAN_PATH_ILK=%~2
				GOTO:endingLoop
			)
	
			rem Specified .pdb cleaning path
			IF !switchVal!==p (
				SHIFT
				set _CLEAN_PATH_PDB=%~2
				GOTO:endingLoop
			)
		
		:doNotClean
			rem Do not clean .lst cleaning path
			IF !switchVal!==L (
				SHIFT
				set _CLEAN_LST=FALSE
				GOTO:endingLoop
			)
	
			rem Do not clean .obj cleaning path
			IF !switchVal!==O (
				SHIFT
				set _CLEAN_OBJ=FALSE
				GOTO:endingLoop
			)
	
			rem Do not clean .exe cleaning path
			IF !switchVal!==E (
				SHIFT
				set _CLEAN_EXE=FALSE
				GOTO:endingLoop
			)
	
			rem Do not clean .ilk cleaning path
			IF !switchVal!==I (
				SHIFT
				set _CLEAN_ILK=FALSE
				GOTO:endingLoop
			)
	
			rem Do not clean .pdb cleaning path
			IF !switchVal!==P (
				SHIFT
				set _CLEAN_PDB=FALSE
				GOTO:endingLoop
			)


		rem This was not a valid switch
		ECHO:Unknown Switch Value: !switchVal!
		GOTO:echoERROR		
	)	
	
	rem Current parameter is not a switch	
	
	rem If the PROJECT NAME hasn't been set yet
	IF NOT DEFINED _CLEAN_PATH (
		set _CLEAN_PATH=%_SCRIPT_ABS%Projects\%var%
		
		rem Set the cleaning paths
		set _CLEAN_PATH_LST=!_CLEAN_PATH!\bin
		set _CLEAN_PATH_OBJ=!_CLEAN_PATH!\bin
		set _CLEAN_PATH_EXE=!_CLEAN_PATH!\bin-int
		set _CLEAN_PATH_ILK=!_CLEAN_PATH!\bin-int
		set _CLEAN_PATH_PDB=!_CLEAN_PATH!\bin-int

		GOTO:endingLoop
	)
	
	:endingLoop
	SHIFT
	GOTO:parameterLoop
:endParameterLoop


:errorChecking
	IF NOT DEFINED _CLEAN_PATH (
		ECHO ***ERROR*** cleanPath or projectName was not set
		GOTO:echoERROR
	)
	
:debugging
	IF %_DEBUG%==TRUE (
		ECHO CleanPath:	%_CLEAN_PATH%

		ECHO.
		
		rem Echo if paths should be cleaned
		ECHO Should clean .lst: %_CLEAN_LST%
		ECHO Should clean .obj: %_CLEAN_OBJ%
		ECHO Should clean .exe: %_CLEAN_EXE%
		ECHO Should clean .ilk: %_CLEAN_ILK%
		ECHO Should clean .pdb: %_CLEAN_PDB%

		ECHO.
		rem Echo cleaning paths
		ECHO .lst CleanPath: %_CLEAN_PATH_LST%
		ECHO .obj CleanPath: %_CLEAN_PATH_OBJ%
		ECHO .exe CleanPath: %_CLEAN_PATH_EXE%
		ECHO .ilk CleanPath: %_CLEAN_PATH_ILK%
		ECHO .pdb CleanPath: %_CLEAN_PATH_PDB%

	)
	
:cleaning
	IF %_DEBUG%==TRUE (
		ECHO.
		ECHO.
		ECHO Cleaning Files
	)
	
	rem Delete all .lst files
	IF %_CLEAN_LST%==TRUE (
		IF %_DEBUG%==TRUE (
			ECHO 	Cleaning .lst files
		)
		
		FOR /F "tokens=*" %%g IN ('dir "%_CLEAN_PATH_LST%\*.lst" /b/s 2^>nul') DO (
			rem Debugging info
			IF %_DEBUG%==TRUE (
				ECHO 		Cleaning: %%g
			)

			del "%%g"
		)
	)
		
	rem Delete all .obj files
	IF %_CLEAN_OBJ%==TRUE (
		IF %_DEBUG%==TRUE (
			ECHO 	Cleaning .obj files
		)
		
		FOR /F "tokens=*" %%g IN ('dir "%_CLEAN_PATH_OBJ%\*.obj" /b/s 2^>nul') DO (
			rem Debugging info
			IF %_DEBUG%==TRUE (
				ECHO 		Cleaning: %%g
			)
			
			del "%%g"
		)
	)

	rem Delete all .exe files
	IF %_CLEAN_EXE%==TRUE (
		IF %_DEBUG%==TRUE (
			ECHO 	Cleaning .exe files
		)
		
		FOR /F "tokens=*" %%g IN ('dir "%_CLEAN_PATH_EXE%\*.exe" /b/s 2^>nul') DO (
			rem Debugging info
			IF %_DEBUG%==TRUE (
				ECHO 		Cleaning: %%g
			)
			
			del "%%g"
		)
	)
	
	rem Delete all .ilk files
	IF %_CLEAN_ILK%==TRUE (
		IF %_DEBUG%==TRUE (
			ECHO 	Cleaning .ilk files
		)
		
		FOR /F "tokens=*" %%g IN ('dir "%_CLEAN_PATH_ILK%\*.ilk" /b/s 2^>nul') DO (
			rem Debugging info
			IF %_DEBUG%==TRUE (
				ECHO 		Cleaning: %%g
			)
			
			del "%%g"
		)
	)

	rem Delete all .pdb files
	IF %_CLEAN_PDB%==TRUE (
		IF %_DEBUG%==TRUE (
			ECHO 	Cleaning .pdb files
		)
		
		FOR /F "tokens=*" %%g IN ('dir "%_CLEAN_PATH_PDB%\*.pdb" /b/s 2^>nul') DO (
			rem Debugging info
			IF %_DEBUG%==TRUE (
				ECHO 		Cleaning: %%g
			)
			
			del "%%g"
		)
	)
	

GOTO:eof
:echoHELP
	ECHO Clean a project/path structure recursively of all .lst, .obj, .exe, .ilk, and .pdb
	ECHO.
	ECHO CleanProject (/c cleanPath ^| projectName) [/d] [/l ^| /L] [/o ^| /O] [/e ^| /E] [/i ^| /i] [/p ^| /P]
	ECHO.
	ECHO 	(/c cleanPath ^| projectName)
	ECHO 		/c			Define cleaning path
	ECHO 		cleanPath		Initial path to clean
	ECHO 		projectName		Project to clean		
	ECHO 	[/d]				Print all information
	ECHO 	[/l ^| /L]			
	ECHO 		/l			Define .lst cleaning path
	ECHO 		/L			Do not clean .lst files
	ECHO 	[/o ^| /O]			
	ECHO 		/o			Define .obj cleaning path
	ECHO 		/O			Do not clean .obj files
	ECHO 	[/e ^| /E]			
	ECHO 		/e			Define .exe cleaning path
	ECHO 		/E			Do not clean .exe files
	ECHO 	[/i ^| /i]			
	ECHO 		/i			Define .ilk cleaning path
	ECHO 		/I			Do not clean .ilk files
	ECHO 	[/p ^| /P]			
	ECHO 		/p			Define .pdb cleanint path
	ECHO 		/P			Do not clean .pdb files	
	GOTO:eof
	
:echoERROR
	ECHO Try CleanProject /?
	GOTO:eof

