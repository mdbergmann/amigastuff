/*
    $VER = 0.1.1

    @author: Manfred Bergmann


    Wrapper for AmigaE compiler/build

    possible arguments:
    1. mode [compile | compile_verbose | build | build_run | build_clean | compile_run | run]
    2. input [filepath]
    3. (opt) debug [echo]: outputs the entered parameters

    version 0.1.1:
        - don't run if compile failed

*/

parse arg mode input debug

signal on halt
signal on break_c

options results

/* Specify your compiler and build tool */
EC = 'EVO'
BUILD = 'Build'

/* check arguments */
if mode = '' then do
    say "ERROR: Unknown mode!"
    exit
end
if input = '' then do
    say "ERROR: Unknown input!"
    exit
end

if debug = 'echo' then do
    say 'mode: 'mode
    say 'input: 'input
    exit
end

/* extract the folder and filename of the file to be compiled */
inputLen = length(input)
p = lastpos('/', input)
if p > 0 then do
    file_name = trim(substr(input, p+1, inputLen-1))
    folder_path = substr(input, 1, p-1)
end
else do
    file_name = input
    folder_path = ''
end
say 'filename: 'file_name
say 'folder: 'folder_path

/* generate the assembly name (stripping away the .e) */
p = lastpos('.', file_name)
if p = 0 then do
    say 'ERROR: Not a valid AmigaE filename, should contain ".e"!'
    exit
end
assembly_name = trim(substr(file_name, 1, p-1))
say 'Assembly name: 'assembly_name

outputname = assembly_name
say 'Output name: 'outputname

/* Now compile and or run */
if mode = 'compile' | mode = 'compile_run' then do
    say 'Compiling...'
    ADDRESS COMMAND EC input
    say 'Compiling...done'
end
else if mode = 'compile_verbose' then do
    say 'Compiling verbose...'
    ADDRESS COMMAND EC input
    say 'Compiling verbose...done'
end
else if mode = 'build' | mode = 'build_run' | mode = 'build_clean' then do
    say 'Building...'

    buildfolder = folder_path

    /* try to find a folder that contains the default .build file */
    /* convention is a maximum of 3 levels from the source file */
    levels = 3
    level = 0
    buildfile_found = 0
    do level=0 to levels by 1 while buildfile_found = 0
        buildfile_path = '.build'
        if length(buildfolder) > 0 then
            buildfile_path = buildfolder'/'buildfile_path
        buildfile_found = exists(buildfile_path)

        if buildfile_found = 0 then do
            buildfolder = extractParentFolder(buildfolder)
        end
    end

    if buildfile_found = 1 then do
        say 'Build file found in: 'buildfolder
        if mode = 'build_clean' then outputname = 'clean'

        say 'Building with target: 'outputname
        ADDRESS COMMAND 'execute golded:add-ons/amigae/scripts/call_build.dos' buildfolder outputname
        say 'Building...done'
    end
    else
        say 'ERROR: No build (.build) file found!'
end

/* run? */
say 'RC: 'RC
if RC <= 0 & (mode = 'compile_run' | mode = 'build_run' | mode = 'run') then do
    if length(folder_path) = 0 then
        exepath = outputname
    else
        exepath = folder_path'/'outputname

    say 'Run...'exepath
    ADDRESS COMMAND exepath
end

exit

extractParentFolder: procedure
    parse arg path
    parentPath = path
    pathLen = length(path)
    p = lastpos('/', path)
    if p > 0 then
        parentPath = substr(path, 1, p-1)
    else
        parentPath = ''

    return parentPath

