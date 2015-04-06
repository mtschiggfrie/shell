%{
	#include <stdio.h>
	#include <stdlib.h>

	#define YYSTYPE char *
	#define max_pipes 5

	typedef enum { FALSE, TRUE } bool;
	typedef int(*fptr)(int, char*[]);

	struct a_cmd {
		char * cmd_name;
		int nargs;
		char * args[];
	};

	char * file_out;	//Redirect STDOUT of final command to file_out
	char * file_in;		//Redirect STDIN of final command to file_in
	bool append = FALSE;//Redirect and append STDOUT of final command to file_out
	bool run_background = FALSE;//Default is to wait for cmds to finish executing

	struct a_cmd * cmdtab[max_pipes];
	int num_cmds = 0;

	/*********************************************/
	/* init_a_cmd - Initializes a_cmd with given 
	cmd_name Then pushes the cmd into next free 
	cmdtab */
	/*********************************************/

	void init_a_cmd(char * cmd_name){
		struct a_cmd * cmd = malloc(sizeof * cmd);
		if(!cmd) //throw mem error
		cmd -> cmd_name = cmd_name;
		cmd -> nargs = 0;
		cmdtab[num_cmds++] = cmd;
	}

	/*********************************************/
	/* add_args - adds arg to most recently read 
	cmd in cmdtab */
	/*********************************************/

	void add_args(char * arg){
		struct a_cmd * cmd = cmdtab[num_cmds];
		(cmd -> args)[(cmd -> nargs)++] = arg;	//add arg into cmd's args, increment nargs
	}

	/*********************************************/
	/* built-in functions
	/*********************************************/

	int sh_setenv(int nargs, char * args[]){}

	int sh_printenv(int nargs, char * args[]){}

	int sh_unsetenv(int nargs, char * args[]){}

	int sh_cd(int nargs, char * args[]){}

	int sh_alias(int nargs, char * args[]){}

	int sh_unalias(int nargs, char * args[]){}

	int sh_bye(int nargs, char * args[]){}

	/*********************************************/
	/*cmdmap - Maps each cmd_name to its proper 
	function */
	/*********************************************/

	fptr sh_cmdmap(char * cmd_name){
		if(cmd_name == "setenv") return &sh_setenv;
		if(cmd_name == "printenv") return &sh_printenv;
		if(cmd_name == "unsetenv") return &sh_unsetenv;
		if(cmd_name == "cd") return &sh_cd;
		if(cmd_name == "alias") return &sh_alias;
		if(cmd_name == "unalias") return &sh_unalias;
		if(cmd_name == "bye") return &sh_bye;

		return 0;
	}

	fptr xsh_cmdmap(char * cmd_name){
		if(cmd_name == "ls") return;

		return 0;
	}

	/*********************************************/
	/* execute_cmds - executes each command in 
	cmdtab */
	/*********************************************/

	void execute_cmds(){
		int i;
		int pid;
		fptr sh_func;
		struct a_cmd * cmd;

		for(i = 0; i < num_cmds; ++i){
			cmd = cmdtab[i];
			
			/* search built-ins */
			if(sh_func = sh_cmdmap(cmd -> cmd_name)){
				//will only be one cmd for built-ins, set a flag after running
				sh_func(cmd -> nargs, cmd -> args);
			}

			/* search non-built-ins */
			else if(sh_func = xsh_cmdmap(cmd -> cmd_name)){
				int j;
				int * pipes[num_cmds];

				for(j = 0; j < num_cmds; ++j){

				}

				/* Test pipe code *//*
				we have num_cmds matched_cmds
				create the pipes and put in pipe_list
				pipe_list = {int pipe_12[2], pipe_23[2], ..., pipe_(n-1)n[2]}
				pid_list = {int pid_1, pid_2, ..., pid_n}

				first cmd case(redirecting STDIN to input_file for pid_1):
					open file_in for first cmd
					dup2(fileno(file_in), STDIN_FILENO)
					fclose(file_in)
					execute process first process
					[error handling]

				for (i=2; i < n; ++i) [1-n chosen]:
					pid_i = fork()
					if pid_i == child:
						dup2(pipe_(i-1)i[0], STDIN_FILENO)
						dup2(pipe_i(i+1)[1], STDOUT_FILENO)
						==
						process i reads from process i-1
						process i writes to process i+1
						close pipes
						execute cmd
						[error handling]
						exit()

				end case(redirecting STDOUT to output_file for final pid):
					open file_out for final cmd
					dup2(fileno(file_out), STDOUT_FILENO)
					fclose(file_out)
					execute process final process
					[error handling]

				if wait for cmds to complete (background_tok)
					wait() n times

				close pipes
				*/
			}
			
			else{
				//no matching cmd found
			}

		}
	}

	void clear_cmds(){
		int i;

		for(i = 0; i < num_cmds; ++i) free(cmdtab[i]);  //release cmd mem for next line of input
		num_cmds = 0; file_in = 0; file_out = 0;		//reset defaults
		append = FALSE; run_background = FALSE;
	}

%}

%token OTHER_TOK INTO_TOK FROM_TOK STDOUT_TOK STDERR_TOK BACKGROUND_TOK PIPE_TOK EOF_TOK

%%


command:
		//init_a_cmd with cmd_name = OTHER_TOK
		OTHER_TOK					{ $$ = $1; init_a_cmd($1);}
		//push arg onto argv
		| command OTHER_TOK			{ $$ = $1; add_args($2);}
		//pipe commands, increment cmd argstack to push args to correct argv later
		| command PIPE_TOK command	{ $$ = $3; init_a_cmd($3);}
		//redirecting already done, just reducing statement
		| command redirect 			{ $$ = $1;}
		//execute command in background
		| command BACKGROUND_TOK 	{ $$ = $1; run_background = TRUE;}
		//execute the commands that have been defined at end of line, then clears cmdtab
		| command '\n'			{ $$ = $1; execute_cmds(); clear_cmds();}
		;

redirect:
		//input redirect always occurs first
		input_redirect { ;}
		//add on output redirect if existing
		| redirect output_redirect { ;}//all remaining redirect is output_redirect

input_redirect:
		//redirect file_in
		FROM_TOK OTHER_TOK			{ file_in = $2;}
		;

output_redirect:
		//redirect file_out
		INTO_TOK OTHER_TOK			{ $$ = $2; file_out = $2;}//output_redirect = file_name
		//redirect 
		| INTO_TOK INTO_TOK			{ $$ = $1; append = TRUE;}//append, push back INTO_TOK
		| STDERR_TOK INTO_TOK STDOUT_TOK	{ ;}//stderr outputs to stdout
		| STDERR_TOK output_redirect		{ ;}//stderr outputs to file_out
		;

%%

//Non-built-ins
//"cat", "ls", "cp", "mv", "rm", "ln", "mkdir", "chown", "chgrp", "chmod", "rmdir", "find"