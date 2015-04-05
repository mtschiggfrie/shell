%{
	#include <stdio.h>
	#include <stdlib.h>

	#define YYSTYPE char *
	typedef enum { FALSE, TRUE } bool;

	struct a_cmd {
		char * cmd_name;
		char * file_out;
		char * file_in;
		int nargs;
		char * args[];
	};

	struct cmdent {
		char * cmd_name;
		// bool built_in;
		int (*cfunc)(int, char*[]);
	};

	struct a_cmd init_a_cmd(char * cmd_name){}
	void clear_a_cmd(){}

	//Store a_cmds in cmdtab[] for handling piping commands. 
	// struct a_cmd cmdtab[];
	// int num_cmds = 0;

	// //Store all valid command names in cmdmap[]
	// //[{cmd_name, built-in, function name}, ...]
	// struct cmdent cmdmap[] = {
	// 	{"bye", TRUE, exit}
	// }
%}

%token OTHER_TOK INTO_TOK FROM_TOK STDOUT_TOK STDERR_TOK BACKGROUND_TOK PIPE_TOK DUMMY_TOK

%%

command:
		//init_a_cmd with cmd_name = OTHER_TOK
		OTHER_TOK					{ $$ = $1; init_a_cmd($1);}
		//push arg onto argv
		| command OTHER_TOK			{ printf("reduced");}
		//pipe commands, increment cmd argstack to push args to correct argv later
		| command PIPE_TOK command	{ ;}
		//change file_out, file_in and stdin,stdout,stderr as appropriate
		| command redirect 			{ ;}
		//execute command in background
		| command BACKGROUND_TOK 	{ ;}
		;

redirect:
		//input redirect always occurs first
		input_redirect				{ ;}
		//add on output redirect if existing
		| redirect output_redirect  { ;}//all remaining redirect is output_redirect
		;

input_redirect:
		//redirect file_in
		FROM_TOK command			{ ;}
		;

output_redirect:
		//redirect file_out
		INTO_TOK command			{ ;}
		//redirect 
		| INTO_TOK STDOUT_TOK		{ ;}//for redirecting stderr to stdout
		| INTO_TOK INTO_TOK			{ ;}//redirect and append (change yylval to >>)
		| STDERR_TOK output_redirect{ ;}
		;

%%

// const struct cmdent cmdtab[] = {
// 	{"bye", 	TRUE, 	bye}
// };

// void setup_table(char * cmd_name){
// 	printf("found bye");
// }

// void clear_table(){}

//BUILT-INS:
//"setenv", "printenv", "unsetenv", "cd", "alias", "unalias", "bye"

//Non-built-ins
//"cat", "ls", "cp", "mv", "rm", "ln", "mkdir", "chown", "chgrp", "chmod", "rmdir", "find"