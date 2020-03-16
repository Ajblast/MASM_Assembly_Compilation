@ECHO off

::*****************************************************************************************
::	File Name:				Assemble
::	Programmer:				Austin Kincer
::	Date Created:			3/14/2020
::	Date Last Modified:		3/15/2020
::	Purpose:				Assemble files in a project or dynamic file structure
::*****************************************************************************************

rem Get the script drive letter
rem Get the script path
rem Get the script absolute path

SETLOCAl EnableDelayedExpansion EnableExtensions
set _SCRIPT_DRIVE=%~d0
set _SCRIPT_PATH=%~p0
set _SCRIPT_ABS=%~dp0

set _ASSEMBLE_PATH=
set _OUPUT_PATH=

set _CLEAN=TRUE

set _DEBUG=FALSE

set _ASSEMBLE_FILES=

rem _FILE_MODE is either none, include, or exclude.
rem 	Include: Add non-switch value to assemble files
rem		Exclude: Remove non-switch value from assemble file
set _FILE_MODE=INCLUDE

rem Create the filesorary files
ECHO. > "%_SCRIPT_ABS%bad"
ECHO. > "%_SCRIPT_ABS%assembleFilePaths"

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
			SHIFT
			set _ASSEMBLE_PATH=%~2
			set _OUPUT_PATH=%~3
			GOTO:endingLoop
		)
		IF !switchVal!==C (			rem Do not clean the project
			set _CLEAN=FALSE
			GOTO:endingLoop
		)
		IF !switchVal!==d (
			set _DEBUG=TRUE
			GOTO:endingLoop
		)
		
		IF !switchVal!==a (
			rem do not add any files to the assembling
			set _FILE_MODE=NONE
			
			rem Skip this if switch if /s was done
			IF %_FILE_MODE%==NONE (
				GOTO:endingLoop
			)
			
			rem For each file, add it to the list of files
			FOR /F "tokens=*" %%g IN ('dir "%_ASSEMBLE_PATH%\*.asm" /b 2^>nul') DO (
				rem set _ASSEMBLE_FILES=!_ASSEMBLE_FILES! %_ASSEMBLE_PATH%\%%g
				ECHO:%_ASSEMBLE_PATH%\%%g>> "%_SCRIPT_ABS%assembleFilePaths"
			)
			GOTO:endingLoop
		)
		IF !switchVal!==s (
			rem do not add any file to the assembling
			set _FILE_MODE=NONE
			
			rem Skip this if switch if /a was done
			IF %_FILE_MODE%==NONE (
				GOTO:endingLoop
			)

			rem For each file, add it to the list of files 
			FOR /F "tokens=*" %%g IN ('dir "%_ASSEMBLE_PATH%\*.asm" /b/s 2^>nul') DO (
				ECHO:%%g>> "%_SCRIPT_ABS%assembleFilePaths"
			)
		)

		IF !switchVal!==x (
			rem do not add any file to the assembling
			set _FILE_MODE=EXCLUDE
			GOTO:endingLoop
		)
		
		rem This was not a valid switch
		ECHO:Unknown Switch Value: !switchVal!
		GOTO:echoERROR		
	)	
	
	rem Current parameter is not a switch	
	
	rem If the _ASSEMBLE_PATH hasn't been set yet
	rem So set it with the very first non-switch argument (Should be project name)
	IF NOT DEFINED _ASSEMBLE_PATH (
		set _ASSEMBLE_PATH=%_SCRIPT_ABS%Projects\%var%
		set _OUPUT_PATH=%_SCRIPT_ABS%Projects\%var%\bin
		GOTO:endingLoop
	)
	
	rem This mode means that non switch values are include file names
	IF %_FILE_MODE%==INCLUDE (
		set var=%~n1
		ECHO:%_ASSEMBLE_PATH%\!var!.asm>> "%_SCRIPT_ABS%assembleFilePaths"
		GOTO:endingLoop
	)
	
	rem This mode means that non switch values are exclude file names
	IF %_FILE_MODE%==EXCLUDE (
		set var=%~n1
		ECHO:!var!>> "%_SCRIPT_ABS%bad"
		GOTO:endingLoop
	)
	
	:endingLoop
	SHIFT
	GOTO:parameterLoop
:endParameterLoop


:errorChecking
	IF NOT DEFINED _ASSEMBLE_PATH (
		ECHO ***ERROR*** Assemble path was not set
		GOTO:echoERROR
	)

:debugging
	IF %_DEBUG%==TRUE (
		ECHO.
		ECHO *********DEBUG INFORMATION*********
		ECHO AssemblePath:	%_ASSEMBLE_PATH%
		ECHO OutputPath:	%_OUPUT_PATH%

		ECHO.
		rem Echo if paths should be cleaned
		ECHO Should clean: %_CLEAN%

		ECHO.
		
		rem Display all assembling files
		ECHO Files found
		FOR /F "tokens=* usebackq" %%g IN ("%_SCRIPT_ABS%assembleFilePaths") DO (
			rem Echo all non empty lines
			IF NOT "%%g"=="" (
				ECHO: 	%%g
			)
		)
				
		ECHO.
		ECHO Files to exclude	

		ECHO. > "%_SCRIPT_ABS%excluded"
		
		rem Determine the files that are excluded
		FOR /F "tokens=* usebackq" %%g IN ("%_SCRIPT_ABS%bad") DO (
			rem Find all file paths that match
			IF NOT "%%g"=="" (
				ECHO:%%g
				findstr /R "^.*%%g\.asm$" "%_SCRIPT_ABS%assembleFilePaths" > "%_SCRIPT_ABS%temp"
				TYPE "%_SCRIPT_ABS%temp" >> "%_SCRIPT_ABS%excluded"
				del "%_SCRIPT_ABS%temp"
			)
		)
		
		rem Print the files to be excluded
		FOR /F "tokens=* usebackq" %%g IN ("%_SCRIPT_ABS%excluded") DO (
			rem Echo all non empty lines
			IF NOT "%%g"=="" (
				ECHO 	%%g
			)
		)
		
		rem Delete the temporary file
		del "%_SCRIPT_ABS%excluded"
		ECHO *********DEBUG INFORMATION*********		
	)

:excludeFiles
	IF %_DEBUG%==TRUE (
		ECHO.
		ECHO Excluding files
	)
	FOR /F "tokens=* usebackq" %%g IN ("%_SCRIPT_ABS%bad") DO (
		IF NOT "%%g"=="" (		
			findstr /V /R /C:".*%%g\.asm" "%_SCRIPT_ABS%assembleFilePaths" > "%_SCRIPT_ABS%temp"
			TYPE "%_SCRIPT_ABS%temp"
			TYPE "%_SCRIPT_ABS%temp" > "%_SCRIPT_ABS%assembleFilePaths"
			del "%_SCRIPT_ABS%temp"
		)
	)

:debuggingFiles
	IF %_DEBUG%==TRUE (
		rem Print the files to be assembled
		ECHO.
		ECHO Files to be actually assembled
		FOR /F "tokens=* usebackq" %%g IN ("%_SCRIPT_ABS%assembleFilePaths") DO (
			rem Echo all non empty lines
			IF NOT "%%g"=="" (
				ECHO 	%%g
			)
		)

	)
		
:fileAppending
	FOR /F "tokens=*" %%g IN ('TYPE "%_SCRIPT_ABS%assembleFilePaths" 2^>nul') DO (
		rem ECHO:%%g
		
		rem Append all non empty lines
		IF NOT "%%g"=="" (
			IF NOT DEFINED _ASSEMBLE_FILES (
				set _ASSEMBLE_FILES=^"%%g^"
			) ELSE (
				set _ASSEMBLE_FILES=!_ASSEMBLE_FILES! ^"%%g^"
			)
		)
	)

	IF %_DEBUG%==TRUE (
		ECHO.
		ECHO Assemble Files Variable: %_ASSEMBLE_FILES%
	)

:assembleFileCheck
	IF NOT DEFINED _ASSEMBLE_FILES (
		ECHO.
		ECHO There are no files to assemble.
		ECHO Exiting...
		GOTO:eof
	)
	
:cleaning
	rem Clean the output path
	IF %_CLEAN%==TRUE (
		rem Debugging
		IF %_DEBUG%==TRUE (
			ECHO.
			ECHO Cleaning target directory
			
			rem Clean the output path with debug information
			CALL Clean /c "%_OUPUT_PATH%" /d
		) ELSE (
			rem Clean the output path
			CALL Clean /c "%_OUPUT_PATH%"
		)
	)
	
:outputPathChecking
	rem Check if the output path exists	
	IF NOT EXIST "%_OUPUT_PATH%" (
		IF %_DEBUG%==TRUE (
			ECHO Output path does not exist. Making directory
		)
		
		rem Make the output path directory
		mkdir "%_OUPUT_PATH%"
	)
	
	IF %_DEBUG%==TRUE (
		ECHO.
		ECHO Changing to ouput directory
	)
	
	rem Change to the ouput
	cd "%_OUPUT_PATH%"
	
:assembling
	rem call the assembler
	IF %_DEBUG%==TRUE (
		ECHO.
		ECHO Assembling...
		ECHO.
		ECHO.
	)
	
	ECHO.
	
	rem TODO: Figure out why I can't do the assembling in one call. It apparently breaks???
	rem 		Current fix, don't delete the file and don't use the variable
	
	rem Assemble each file
	FOR /F "tokens=*" %%g IN ('TYPE "%_SCRIPT_ABS%assembleFilePaths" 2^>nul') DO (
		IF NOT "%%g"=="" (
			CALL "%_SCRIPT_ABS%MASM\ml.exe" /c /coff /Zi /Fl "%%g"
			ECHO.
		)
	)
		
:pathCorrection
	rem Move back up the file tree to the starting path
	IF %_DEBUG%==TRUE (
		ECHO.
		ECHO Changing to original script directory
	)
	
	rem Change back to the original directory
	cd "%_SCRIPT_ABS%"
	
:temporaryFileDeletion
	rem Delete the filesorary files
	IF %_DEBUG%==TRUE (
		ECHO.
		ECHO Deleting temporary files
	)
	
	del "%_SCRIPT_ABS%bad"
	del "%_SCRIPT_ABS%assembleFilePaths"


GOTO:eof
:echoHELP
	ECHO Assemble files in a project/path structure
	ECHO.
	ECHO Assemble ({/p assemblePath outputPath} ^| projectName) [/C] [/d] [/a ^| /s ^| fileNames] [/x fileNames]
	ECHO.
	ECHO 	({/p assemblePath outputPath} ^| projectName)
	ECHO 		/p					Define the path to look for assemblable files
	ECHO 		assemblePath				Path to look for assemblable files
	ECHO 		outputPath				Path to output to
	ECHO 		projectName				Name of the project
	ECHO 	[/C]						Do not clean before assembling
	ECHO 	[/d]						Print all information
	ECHO 	[/a ^| /s ^| fileNames]
	ECHO 		/a					Assemble all .asm
	ECHO 		/s					Assemble all .asm recursively
	ECHO 		fileNames				Names of the files to assemble
	ECHO 							Looks in assemblePath if defined or in the project folder
	ECHO 	[/x fileNames]
	ECHO 		/x					Exclude the following files from assembling
	ECHO 		fileNames				Names of the file to not assemble
	ECHO 							Looks in assemblePath if defined or in the project folder
	GOTO:temporaryFileDeletion
	
:echoERROR
	ECHO Try Assemble /?
	GOTO:temporaryFileDeletion
