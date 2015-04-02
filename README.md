# COP4600 shell

README will organize the current status of project/ideas/non-immediate questions for each other. We can alter/expand the blueprint to keep track of everything or ignore it if we find it unhelpful.

##Blueprint
TOKENS:
> \> = INTO_TOK

> < = FROM_TOK

> | = PIPE_TOK

> & = BACKGROUND_TOK

> 2 = STDERR_TOK

> &1 = STDOUT_TOK

> CMD or ARG or FILENAME or "..."='...' = OTHER_TOK

> possibly tokens for the built-in commands (setenv, printenv, unsetenv, cd, alias, unalias, bye)

ASSUMPTION and THOUGHTS:
> First OTHER_TOK always CMD. Same for OTHER_TOK after a PIPE_TOK

> The expression can be reduced in any order as the shell executes the command all at once.

> "...." tokens will need to be reduced into their component tokens somehow for the grammar to be unambiguous.

> If we accomplish that then any OTHER_TOK + OTHER_TOK will be arg + arg or cmd + arg, which is still uniquely identified.

> yylval will then be a string always (">', 'echo', '2', 'test'). 

> Because we know the string is going to be either a cmd or an arg or a '>' we can build a table or some other mapping for the cmds. The args can be pushed to a stack and popped at execution. Filenames are easy, nothing needs to be done there. 

> Whitespace will need to be trimmed from the yylval in lex. Metacharacter recognition and handling will also require Lex. 

> Yacc will manage the reduction of the tokens and construction of the commands to be executed, so it will be handling the syscalls.

> Wild-Carding looks like its Lex work

> None of this has taken into account aliasing.

##Current Project Status:
1. Outline complete

##Needs to be completed:
1. Everything
