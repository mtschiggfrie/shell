%{
	#include <stdio.h>
	#include <stdlib.h>

	/* Declarations */

	#define YYSTYPE char *
	typedef enum { FALSE, TRUE } bool;
	typedef int(*fptr)(int, char*[]);

	struct a_cmd {
		char * cmd_name;
		char * file_out;
		char * file_in;
		int nargs;
		char * args[];
	};

	struct a_cmd cmdtab[5];
	int num_cmds = 0;

	/*********************************************/
	/* init_a_cmd - Initializes a_cmd with given 
	cmd_name Then pushes the cmd into next free 
	cmdtab */
	/*********************************************/

	void init_a_cmd(char * cmd_name){
		struct a_cmd cmd;
		cmd.cmd_name = cmd_name;
		cmd.nargs = 0;
		cmdtab[num_cmds++] = cmd;
	}

	/*********************************************/
	/* add_args - adds arg to most recently read 
	cmd in cmdtab */
	/*********************************************/

	void add_args(char * arg){
		struct a_cmd cmd = cmdtab[num_cmds];
		cmd.args[cmd.nargs++] = arg;
	}

	/*********************************************/
	/*cmdmap - Maps each cmd_name to its proper 
	function */
	/*********************************************/

	fptr cmdmap(char * cmd_name){
		fptr cfunc;
		if(cmd_name == "cd") return chdir();
		if(cmd_name == "bye") return exit;

		return 0;
	}

	/*********************************************/
	/* execute_cmds - executes each command in 
	cmdtab */
	/*********************************************/

	void execute_cmds(){

	}

%}

%token OTHER_TOK INTO_TOK FROM_TOK STDOUT_TOK STDERR_TOK BACKGROUND_TOK PIPE_TOK DUMMY_TOK

%%

command:
		//init_a_cmd with cmd_name = OTHER_TOK
		OTHER_TOK					{ $$ = $1; init_a_cmd($1);}
		//push arg onto argv
		| command OTHER_TOK			{ add_args($2);}
		//pipe commands, increment cmd argstack to push args to correct argv later
		| command PIPE_TOK command	{ ;}
		//change file_out, file_in and stdin,stdout,stderr as appropriate
		| command redirect 			{ ;}
		//execute command in background
		| command BACKGROUND_TOK 	{ ;}
		//execute the commands that have been defined at end of line
		| command '\n'				{ execute_cmds();}
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

//BUILT-INS:
//"setenv", "printenv", "unsetenv", "cd", "alias", "unalias", "bye"

//Non-built-ins
//"cat", "ls", "cp", "mv", "rm", "ln", "mkdir", "chown", "chgrp", "chmod", "rmdir", "find"