# COP4600 shell

Eric Kaschalk and Matthew Tschiggfrie


Features not implemented:
1. Extra credit
2. setenv of envvar with colon seperated words or large "..."
3.

Features Implemented:
1. All built-in functions
2. Non-built-in functions (predefined, thought to be inclusive of main unix commands, included functions defined in xsh_cmdmap in cmd_funcs.H)
3. Aliases
4. Env variable expansions
5. Wildcard matching
6. Piping of non-built-ins
7. I/O redirection (input, output, append)
8. Background running
9. Graceful error handling (no exiting of shell)
10.

Idiosyncrasies:
1. Feeding from input file works (./shell.exe < testfile.txt) but doesn't close shell after execution, need to restart shell.
2. running in the background functions but can cause print statements to come after prepending currdir
3. 