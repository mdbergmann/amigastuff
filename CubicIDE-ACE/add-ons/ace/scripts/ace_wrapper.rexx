/*
    $VER = 0.0.1

    @author: Manfred Bergmann


    Wrapper for ACE compiler/build

    possible arguments:
    1. mode [compile | compile_run | run | clean]
    2. input [filepath]
    3. (opt) flags:
        [echo]: outputs the entered parameters
        [optimize]: optimize compile

*/

parse arg mode input flags

signal on halt
signal on break_c

options results

/* Specify your compiler and build tool */
APP = 'ACPP' /* 'APP' */
RL = 'RemoveLine'
ACE = 'ACE'
AS = 'a68k'
LNK = 'blink'

/* check arguments */
if mode = '' then do
    say "ERROR: Unknown mode!"
    exit
end
if input = '' then do
    say "ERROR: Unknown input!"
    exit
end

if flags = 'echo' then do
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

/* generate the assembly name (stripping away the .b) */
p = lastpos('.', file_name)
if p = 0 then do
    say 'ERROR: Not a valid ACE Basic filename, should contain ".b"!'
    exit
end
assembly_name = trim(substr(file_name, 1, p-1))
say 'Assembly name: 'assembly_name

outputname = assembly_name
say 'Output name: 'outputname

err = 0
/* Now compile and or run */
if mode = 'compile' | mode = 'compile_run' then do
    say 'Preprocessing...'
    pre_outname = outputname'.pre'
    ADDRESS COMMAND APP input pre_outname
    call assertNoError('pre-processing')
    say 'Preprocessing...done'
    say 'pre-processing stage 2...'
    pre2_outname = outputname'.pre2'
    ADDRESS COMMAND RL pre_outname pre2_outname'.b'
    call assertNoError('pre-processing2')
    say 'pre-processing stage 2...done'
    say 'Compiling...'
    ADDRESS COMMAND ACE pre2_outname
    say 'Compiling...done'
    call assertNoError('compile')

    if mode = 'compile_run' then do
        say 'Assembling...'
        ADDRESS COMMAND AS outputname'.s'
        say 'Assembling...done'
        call assertNoError('assemble')
        say 'Linking...'
        ADDRESS COMMAND LNK FROM outputname'.o' 'LIB ace:lib/db.lib ace:lib/ami.lib ace:lib/startup.lib TO 'outputname
        say 'Linking...done'
        call assertNoError('linking')
    end
end
else if mode = 'run' then do
    RC = 0
end
else if mode = 'clean' then do
    say 'Deleting generated files...'
    ADDRESS COMMAND Delete outputname'.pre'
    ADDRESS COMMAND Delete outputname'.pre2.b'
    ADDRESS COMMAND Delete outputname'.s'
    ADDRESS COMMAND Delete outputname'.o'
    ADDRESS COMMAND Delete outputname
    say 'Deleting generated files...done'
end

/* run? */
say 'RC: 'RC
if RC <= 0 & (mode = 'compile_run' | mode = 'run') then do
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

assertNoError: procedure expose RC
    parse arg label
    say 'RC: 'RC
    if RC > 0 then do
        say 'Error on 'label'!'
        exit
    end

