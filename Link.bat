@ECHO off

::*****************************************************************************************
::	File Name:				Link
::	Programmer:				Austin Kincer
::	Date Created:			3/14/2020
::	Date Last Modified:		3/15/2020
::	Purpose:				Link files in a project or dynamic file structure
::*****************************************************************************************

rem Get the script drive letter
rem Get the script path
rem Get the script absolute path

SETLOCAl EnableDelayedExpansion EnableExtensions
set _SCRIPT_DRIVE=%~d0
set _SCRIPT_PATH=%~p0
set _SCRIPT_ABS=%~dp0

set _LINK_PATH=
set _OUPUT_PATH=
set _INCLUDE_PATH=
set _EXECUTABLE=
set _ENTRY=

set _CLEAN=TRUE
set _INCLUDE=FALSE

set _DEBUG=FALSE

set _LINK_FILES=

rem _FILE_MODE is either none, include, or exclude.
rem 	Include: Add non-switch value to assemble files
rem		Exclude: Remove non-switch value from assemble file
set _FILE_MODE=INCLUDE

rem Create the filesorary files
ECHO. > "%_SCRIPT_ABS%bad"
ECHO. > "%_SCRIPT_ABS%linkFilePaths"
ECHO. > "%_SCRIPT_ABS%includeFilePaths"

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
			SHIFT
			SHIFT
			set _LINK_PATH=%~2
			set _OUPUT_PATH=%~3
			set _INCLUDE_PATH=%~4
			set _EXECUTABLE=%~n5
			GOTO:endingLoop
		)
				
		IF !switchVal!==i (
			set _INCLUDE=TRUE
			
			rem For each file, add it to the list of files
			FOR /F "tokens=*" %%g IN ('dir "%_INCLUDE_PATH%\*.???" /b 2^>nul') DO (
				ECHO:%_INCLUDE_PATH%\%%g>> "%_SCRIPT_ABS%includeFilePaths"
			)
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
			FOR /F "tokens=*" %%g IN ('dir "%_LINK_PATH%\*.???" /b 2^>nul') DO (
				ECHO:%_LINK_PATH%\%%g>> "%_SCRIPT_ABS%linkFilePaths"
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
			FOR /F "tokens=*" %%g IN ('dir "%_LINK_PATH%\*.???" /b/s 2^>nul') DO (
				ECHO:%%g>> "%_SCRIPT_ABS%linkFilePaths"
			)
		)

		IF !switchVal!==x (
			rem do not add any file to the assembling
			set _FILE_MODE=EXCLUDE
			GOTO:endingLoop
		)
		
		IF !switchVal!==e (
			rem Set the entry label
			set _ENTRY=%~2
			GOTO:endingLoop
		)
		
		rem This was not a valid switch
		ECHO:Unknown Switch Value: !switchVal!
		GOTO:echoERROR		
	)	
	
	rem Current parameter is not a switch	
	
	rem If the _LINK_PATH hasn't been set yet
	rem So set it with the very first non-switch argument (Should be project name)
	IF NOT DEFINED _LINK_PATH (
		set _LINK_PATH=%_SCRIPT_ABS%Projects\%var%\bin
		set _OUPUT_PATH=%_SCRIPT_ABS%Projects\%var%\bin-int
		set _INCLUDE_PATH=%_SCRIPT_ABS%Projects\%var%\include
		set _EXECUTABLE=%var%
		set _ENTRY=start

		rem Check if the optional executable name was given
		set nextArg=%~2
		IF "!nextArg!"=="/E" (
			set _EXECUTABLE=%~3
			
			rem Shift 2 arguments down
			SHIFT
			SHIFT
		)
		
		GOTO:endingLoop
	)
	
	rem This mode means that non switch values are include file names
	IF %_FILE_MODE%==INCLUDE (
		set var=%~nx1
		ECHO:%_LINK_PATH%\!var!>> "%_SCRIPT_ABS%linkFilePaths"
		GOTO:endingLoop
	)
	
	rem This mode means that non switch values are exclude file names
	IF %_FILE_MODE%==EXCLUDE (
		set var=%~nx1
		ECHO:!var!>> "%_SCRIPT_ABS%bad"
		GOTO:endingLoop
	)
	
	:endingLoop
	SHIFT
	GOTO:parameterLoop
:endParameterLoop


:errorChecking
	IF NOT DEFINED _LINK_PATH (
		ECHO ***ERROR*** Assemble path was not set
		GOTO:echoERROR
	)
	IF NOT DEFINED _OUPUT_PATH (
		ECHO ***ERROR*** Output path was not set
		GOTO:echoERROR
	)
	IF NOT DEFINED _INCLUDE_PATH (
		ECHO ***ERROR*** Include path was not defined
		GOTO:echoERROR
	)
	IF NOT DEFINED _EXECUTABLE (
		ECHO ***ERROR*** Executable name was not set
		GOTO:echoERROR
	)
	IF NOT DEFINED _ENTRY (
		ECHO ***ERROR*** Entry point was not defined
		GOTO:echoERROR
	)
	
:excludeNonLinkableFiles
	IF %_DEBUG%==TRUE (
		ECHO.
		ECHO Excluding non linkable files
	)
	IF NOT EXIST "%_SCRIPT_ABS%LinkableFileTypes.txt" (
		ECHO.
		ECHO ***ERROR*** "%_SCRIPT_ABS%LinkableFileTypes.txt" does not exists
		GOTO:echoERROR
	)
	
	rem Create the temporary file
	ECHO. > "%_SCRIPT_ABS%temp"
	
	FOR /F "tokens=* usebackq" %%g IN ("%_SCRIPT_ABS%LinkableFileTypes.txt") DO (
		rem If the line is not empty
		IF NOT "%%g"=="" (
			rem Get all items that match the linkable file types and append them
			findstr /R "^.*%%g\....$ ^.*%%g$" "%_SCRIPT_ABS%linkFilePaths" >> "%_SCRIPT_ABS%temp"
		)
	)
	
	rem Replace the "%_SCRIPT_ABS%linkFilePaths" with the actually linkable files
	TYPE "%_SCRIPT_ABS%temp" > "%_SCRIPT_ABS%linkFilePaths"
	
	rem Delete the temporary files
	del "%_SCRIPT_ABS%temp"
	
:excludeNonLinkableIncludeFiles
	IF %_DEBUG%==TRUE (
		ECHO.
		ECHO Excluding non linkable include files
	)
	IF NOT EXIST "%_SCRIPT_ABS%LinkableFileTypes.txt" (
		ECHO.
		ECHO ***ERROR*** "%_SCRIPT_ABS%LinkableFileTypes.txt" does not exists
		GOTO:echoERROR
	)
	
	rem Create the temporary file
	ECHO. > "%_SCRIPT_ABS%temp"
	
	FOR /F "tokens=* usebackq" %%g IN ("%_SCRIPT_ABS%LinkableFileTypes.txt") DO (
		rem If the line is not empty
		IF NOT "%%g"=="" (
			rem Get all items that match the linkable file types and append them
			findstr /R "^.*%%g\....$ ^.*%%g$" "%_SCRIPT_ABS%includeFilePaths" >> "%_SCRIPT_ABS%temp"
		)
	)
	
	rem Replace the "%_SCRIPT_ABS%includeFilePaths" with the actually linkable files
	TYPE "%_SCRIPT_ABS%temp" > "%_SCRIPT_ABS%includeFilePaths"
	
	rem Delete the temporary files
	del "%_SCRIPT_ABS%temp"

:debugging
	IF %_DEBUG%==TRUE (
		ECHO.
		ECHO *********DEBUG INFORMATION*********
		ECHO LinkPath:	%_LINK_PATH%
		ECHO OutputPath:	%_OUPUT_PATH%
		ECHO IncludePath:	%_INCLUDE_PATH%
		ECHO Executable:	%_EXECUTABLE%
		ECHO Entry:		%_ENTRY%
		ECHO.
		
		rem Echo if paths should be cleaned
		ECHO Should clean: 		%_CLEAN%
		ECHO Should include: 	%_INCLUDE%

		
		rem Display all linking files
		ECHO.
		ECHO Files found
		FOR /F "tokens=* usebackq" %%g IN ("%_SCRIPT_ABS%linkFilePaths") DO (
			rem Echo all non empty lines
			IF NOT "%%g"=="" (
				ECHO: 	%%g
			)
		)
		
		rem Display all include linking files
		ECHO.
		ECHO Include files found
		FOR /F "tokens=* usebackq" %%g IN ("%_SCRIPT_ABS%includeFilePaths") DO (
			rem Echo all non empty lines
			IF NOT "%%g"=="" (
				ECHO: 	%%g
			)
		)

		rem Determine the files that are to be excluded
		ECHO.
		ECHO Files to exclude	

		ECHO. > "%_SCRIPT_ABS%excluded"

		FOR /F "tokens=* usebackq" %%g IN ("%_SCRIPT_ABS%bad") DO (
			IF NOT "%%g"=="" (
				rem Find all file paths that match with or without file extension
				findstr /R "^.*%%g\....$ ^.*%%g$" "%_SCRIPT_ABS%linkFilePaths" > "%_SCRIPT_ABS%temp"
				TYPE "%_SCRIPT_ABS%temp" >> "%_SCRIPT_ABS%excluded
				del "%_SCRIPT_ABS%temp""
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
			findstr /V /R "^.*%%g\....$ ^.*%%g$" "%_SCRIPT_ABS%linkFilePaths" > "%_SCRIPT_ABS%temp"
			TYPE "%_SCRIPT_ABS%temp" > "%_SCRIPT_ABS%linkFilePaths"
			del "%_SCRIPT_ABS%temp"
		)
	)

:debuggingFiles
	IF %_DEBUG%==TRUE (
		rem Print the files to be assembled
		ECHO.
		ECHO Files to be actually linked
		ECHO 	Linkable Files
		FOR /F "tokens=* usebackq" %%g IN ("%_SCRIPT_ABS%linkFilePaths") DO (
			rem Echo all non empty lines
			IF NOT "%%g"=="" (
				ECHO 		%%g
			)
		)
		
		ECHO 	Include Files
		FOR /F "tokens=* usebackq" %%g IN ("%_SCRIPT_ABS%includeFilePaths") DO (
			rem Echo all non empty lines
			IF NOT "%%g"=="" (
				ECHO 		%%g
			)
		)

	)
			
:fileAppending
	rem Append linkable files
	FOR /F "tokens=*" %%g IN ('TYPE "%_SCRIPT_ABS%linkFilePaths" 2^>nul') DO (
		rem ECHO:%%g
		
		rem Append all non empty lines
		IF NOT "%%g"=="" (
			IF NOT DEFINED _LINK_FILES (
				set _LINK_FILES=^"%%g^"
			) ELSE (
				set _LINK_FILES=!_LINK_FILES! ^"%%g^"
			)
		)
	)
	
	rem Append include linkable files
	FOR /F "tokens=*" %%g IN ('TYPE "%_SCRIPT_ABS%includeFilePaths" 2^>nul') DO (
		rem ECHO:%%g
		
		rem Append all non empty lines
		IF NOT "%%g"=="" (
			IF NOT DEFINED _LINK_FILES (
				set _LINK_FILES=^"%%g^"
			) ELSE (
				set _LINK_FILES=!_LINK_FILES! ^"%%g^"
			)
		)
	)


	IF %_DEBUG%==TRUE (
		ECHO.
		ECHO Link Files Variable: %_LINK_FILES%
	)
	
:linkFileCheck
	IF NOT DEFINED _LINK_FILES (
		ECHO.
		ECHO There are no files to link.
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
	
:linking
	rem call the linker
	IF %_DEBUG%==TRUE (
		ECHO.
		ECHO Linking...
		ECHO.
		ECHO.
	)
	
	ECHO.
	
	rem GOTO:eof
	
	CALL "%_SCRIPT_ABS%MASM\link.exe" /debug /subsystem:console /entry:%_ENTRY% /out:"%_OUPUT_PATH%\%_EXECUTABLE%.exe"  %_LINK_FILES% "%_SCRIPT_ABS%MASM\kernel32.lib"

		
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
	del "%_SCRIPT_ABS%linkFilePaths"
	del "%_SCRIPT_ABS%includeFilePaths"

GOTO:eof
:echoHELP
	ECHO Link files in a project/path structure
	ECHO.
	ECHO Link ({/p linkPath outputPath includePath executableName} ^| projectName) [/i] [/C] [/d] [/a ^| /s ^| fileNames] [/x fileNames] [/e label]
	ECHO.
	ECHO 	({/p linkPath outputPath includePath executableName} ^| {projectName [/E executableName]})
	ECHO 		linkPath		Path to look for linkable files
	ECHO 		outputPath		Path to output to
	ECHO 		includePath		Path to include files from
	ECHO 		executableName		Name of the executable
	ECHO 		projectName		Name of the project to look for
	ECHO 	[/i]
	ECHO 		/i			Link all .obj in subfolder Include
	ECHO 		includePath		Path to include linkable files
	ECHO 	[/C]				Do not clean before linking
	ECHO 	[/d]				Print all information
	ECHO 	[/a ^| /s ^| fileNames]
	ECHO 		/a			Link all .obj into executable
	ECHO 		/s			Link all .obj recursively
	ECHO 		fileNames		Names of the files to link
	ECHO 					Looks in linkPath if defined or in the project bin folder
	ECHO 	[/x fileNames]
	ECHO 		/x			Exclude the following files from linking
	ECHO 		fileNames		Names of the file to not link
	ECHO 	[/e label]
	ECHO 		/e			Define the entry label
	ECHO 		label			Entry label
	GOTO:temporaryFileDeletion
	
:echoERROR
	ECHO Try link /?
	GOTO:temporaryFileDeletion
