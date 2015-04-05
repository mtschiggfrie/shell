%{
	#include <stdio.h>
	#include <stdlib.h>

	#define YYSTYPE char *
	typedef enum { FALSE, TRUE } bool;

	void setup_table(char * cmd_name){}
	void clear_table(){}
	void bye(){printf("found bye");}
%}

%token OTHER_TOK INTO_TOK FROM_TOK STDOUT_TOK STDERR_TOK BACKGROUND_TOK PIPE_TOK DUMMY_TOK

%%

command:
		name '\n'	 				{ clear_table();}//gets the name after reading all entered tokens, executes it
		|
		;

name:
		OTHER_TOK					{ $$ = $1; setup_table($1);}//initial OTHER_TOK will be the cmd, next args
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

//BUILT-INS:
//"setenv", "printenv", "unsetenv", "cd", "alias", "unalias", "bye"

//Non-built-ins
//"cat", "ls", "cp", "mv", "rm", "ln", "mkdir", "chown", "chgrp", "chmod", "rmdir", "find"

struct cmd {
	char * cmd_name;
	char * file_out;
	char * file_in;
	int nargs;
	char * args[];
};

struct cmdent {
	char * cmd_name;
	bool built_in;
	int (*cfunc)(int,char*[]);
};

const struct cmdent cmdtab[] = {
	{"bye", 	TRUE, 	bye}
};

// void setup_table(char * cmd_name){
// 	printf("found bye");
// }

// void clear_table(){}