%{

	#include <stdio.h>
	#include <stdlib.h>

%}


%token OTHER_TOK INTO_TOK FROM_TOK STDOUT_TOK STDERR_TOK BACKGROUND_TOK PIPE_TOK

%%

command:
		name '\n'	 				{ ;}//gets the name after reading all entered tokens
		;

name:
		OTHER_TOK					{ ;}//initial OTHER_TOK will be the cmd, next args
		| name PIPE_TOK name		{ ;}//name reduces to cmd_name so concatenate and store in yylval using some delimiter. Also increment name counter and push following args to correct argstack.
		| name OTHER_TOK			{ ;}//push arg onto argstack, set back to name
		| name redirect 			{ ;}//create redirects
		| name BACKGROUND_TOK 		{ ;}//run in background
		;

redirect:
		input_redirect				{ ;}//input redirect always occurs first
		| redirect output_redirect  { ;}//all remaining redirect is output_redirect
		;

input_redirect:
		FROM_TOK name				{ ;}
		;

output_redirect:
		INTO_TOK name				{ ;}
		| INTO_TOK STDOUT_TOK		{ ;}//for redirecting stderr to stdout
		| INTO_TOK INTO_TOK			{ ;}//redirect and append (change yylval to >>)
		| STDERR_TOK output_redirect{ ;}
		;

%%