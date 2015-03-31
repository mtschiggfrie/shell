# COP4600 shell

README will organize the current status of project/ideas/non-immediate questions for each other. We can alter/expand the blueprint to keep track of everything or ignore it if we find it unhelpful.

##Current Questions:
Need to decide on tokens. Tokens we will need for sure:
\> - INTO or GREATER
< - FROM or LESS
| - PIPE
& - AMPER

Bigger issue is to decide how to tokenize strings/names. yylval being an int is nice for the single character tokens but leaves the issue of how to hold the value "cd". My idea is to follow the book's approach, transforming each string/name into its own token OTHER. (e.g. echo test > foo -> OTHER OTHER INTO OTHER, echo "test > foo" -> OTHER OTHER) Then we can parse each OTHER token again to deconstruct the quoted section into its component tokens (not sure how we can accomplish this because of yyparse()). We can set the corresponding yylval then to char * instead, ie. INTO's corresponding yyval is ">" always but OTHER = "cd" or "ls" (but hopefully not OTHER = "test > foo" as that will have been reduced to OTHER INTO OTHER)

My main question is what constitutes simple commands, are they the commands where I/O redirect doesn't make sense (ls, cd, exit, rest of the list)? I believe this is the right reasoning as these commands have different syntax, and thus grammar, from eachother. In this case we would have the tokens as already defined plus the OTHER tokens for strings and commands following the cmd [args]* [|cmd ...].... format.

##Current Project Status:
1. Outline complete

##Needs to be completed:
1. Everything
