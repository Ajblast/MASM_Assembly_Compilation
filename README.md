# MASM_Assembly_Compilation
Simple batch scripts to make assembling/link/debug process easier.


# Batch Scripts
---
## Assemble
Assemble files in a project/path structure

```
Assemble ({/p assemblePath outputPath} | projectName) [/C] [/d] [/a | /s | fileNames] [/x fileNames]


({/p assemblePath outputPath} | projectName)
	/p					Define the path to look for assemblable files
	assemblePath				Path to look for assemblable files
	outputPath				Path to output to
	projectName				Name of the project
[/C]						Do not clean before assembling
[/d]						Print all information
[/a | /s | fileNames]
	/a					Assemble all .asm
	/s					Assemble all .asm recursively
	fileNames				Names of the files to assemble
						Looks in assemblePath if defined or in the project folder
[/x fileNames]
	/x					Exclude the following files from assembling
	fileNames				Names of the file to not assemble
						Looks in assemblePath if defined or in the project folder
```

## Link
Link files in a project/path structure

```
Link ({/p linkPath outputPath includePath executableName} | projectName) [/i] [/C] [/d] [/a | /s | fileNames] [/x fileNames] [/e label]

({/p linkPath outputPath includePath executableName} | {projectName [/E executableName]})
	linkPath		Path to look for linkable files
	outputPath		Path to output to
	includePath		Path to include files from
	executableName		Name of the executable
	projectName		Name of the project to look for
[/i]
	/i			Link all .obj in subfolder Include
	includePath		Path to include linkable files
[/C]				Do not clean before linking
[/d]				Print all information
[/a | /s | fileNames]
	/a			Link all .obj into executable
	/s			Link all .obj recursively
	fileNames		Names of the files to link
				Looks in linkPath if defined or in the project bin folder
[/x fileNames]
	/x			Exclude the following files from linking
	fileNames		Names of the file to not link
[/e label]
	/e			Define the entry label
	label			Entry label
```
## Debug
Debug executable in a project or dynamic file structure

```
Debug ({/p executablePath} | projectName [/E executableName]) [/d]

({/p executablePath} | projectName [/E executableName])
	/p					Define the path for the executable
	executablePath				Executable path
	projectName				Name of the project
	executableName				Name of the executable
[/d]						Print all information
```

## Clean
Clean a project/path structure recursively of all .lst, .obj, .exe, .ilk, and .pdb

```
CleanProject (/c cleanPath | projectName) [/d] [/l | /L] [/o | /O] [/e | /E] [/i | /i] [/p | /P]

(/c cleanPath | projectName)
	/c			Define cleaning path
	cleanPath		Initial path to clean
	projectName		Project to clean		
[/d]				Print all information
[/l | /L]			
	/l			Define .lst cleaning path
	/L			Do not clean .lst files
[/o | /O]			
	/o			Define .obj cleaning path
	/O			Do not clean .obj files
[/e | /E]			
	/e			Define .exe cleaning path
	/E			Do not clean .exe files
[/i | /i]			
	/i			Define .ilk cleaning path
	/I			Do not clean .ilk files
[/p | /P]			
	/p			Define .pdb cleanint path
	/P			Do not clean .pdb files	
```

## CreateProject
Create a project folder structure

```
CreateProject projectName [/i] [/e | {/c fileName}]

projectName				Name of the project.
[/i]					Create an include folder
[/e | {/c fileName}]		
	/e				Indicates to not create a .asm file
	/c				Create a .asm with file name
	fileName			Name of the file.
```
## AddASM
Add a .asm file to a project

```
AddASM projectName [/d | /e] [/f] [fileName]

projectName		Name of the project to add the file
[/d | /e]
	/d		Specifies default file template
	/e		Specifies empty file template
[/f]			Fill .asm with fill values (Create date, Project Name, etc.)
fileName		Name of the file. Defaults to project name when not present
```

# Files
---
## LinkableFileTypes.txt
File containing all of the linkable extensions.

# Templates
---
  Currently only two types of file templates are supported. Dynamic templates are to come.

## Default
  A default .asm file with basic information filled in and some commands.

## Empty
  One of the smallest possible files that can properly assemble/link/execute
