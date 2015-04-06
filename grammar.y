%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <unistd.h> 
	#include <string.h>
	
	#define YYSTYPE char *
	#define MAXENVVARS 10
	#define MAXALIASES 10
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

	bool read_cmd = TRUE;//Flag for init_or_addarg to decide which function to call on reading OTHER_TOK

	struct a_cmd * cmdtab[max_pipes];
	int num_cmds = 0;
	
	char* env_vars[MAXENVVARS][2];  //env_vars[0][0] = variable and env_vars[0][1] = word
	int num_env_vars = 0;
	
	char* alias[MAXALIASES][2];  		 //alias[0][0] = name of alias and alias[0][1] = the cmd in a string
	int num_alias = 0;

	/*********************************************/
	/* init_a_cmd - Initializes a_cmd with given 
	cmd_name Then pushes the cmd into next free 
	cmdtab */
	/* add_args - adds arg to most recently read 
	cmd in cmdtab */
	/* init_or_addarg - chooses which f to call */
	/*********************************************/

	void init_a_cmd(char * cmd_name){
		struct a_cmd * cmd = malloc(sizeof * cmd);
		if(!cmd) //throw mem error
		cmd -> cmd_name = cmd_name;
		cmd -> nargs = 0;
		cmdtab[num_cmds++] = cmd;
	}

	void add_args(char * arg){
		struct a_cmd * cmd = cmdtab[num_cmds - 1]; //current command
		(cmd -> args)[(cmd -> nargs)++] = arg;	//add arg into cmd's args, increment nargs
	}

	void init_or_addarg(char * name){
		if(read_cmd == FALSE){
			printf("%s-arg\n", name); 
			add_args(name);
		}
		if(read_cmd == TRUE){
			printf("%s-cmd\n", name); 
			init_a_cmd(name);
			read_cmd = FALSE;
		}
	}

	/*********************************************/
	/* built-in functions
	/*********************************************/


	int sh_setenv(int nargs, char * args[]){
		if(nargs > 3){
			//too many args throw error
		}
		if(nargs < 3){
			//too little args throw error
		}
		if(MAXENVVARS == num_env_vars){
			//throw error; array full
			//return -1 for error?
		}
		else{
			env_vars[num_env_vars][0] = args[1];
			env_vars[num_env_vars][1] = args[2];
			num_env_vars++;
			//return 1 for success?
		}
	}

	int sh_printenv(int nargs, char * args[]){
		if(nargs > 1){
			//too many args throw error
		}
		if(num_env_vars == 0){
			printf("You currently do not have any environmental variables.");
		}
		else{
			int i;
			for(i = 0; i < num_env_vars; ++i){
			char str_output[100]={0};
			strcpy(str_output, env_vars[i][0]);
			strcat(str_output, " = ");
			strcat(str_output, env_vars[i][1]);
			printf("%s\n", str_output);
			}
		}
		//always return 1 because never fails?
	}

	int sh_unsetenv(int nargs, char * args[]){
		if(nargs > 2){
			//too many args throw error
		}
		if(nargs < 2){
			//not enough args throw error
		}
		int i;
		for(i = 0; i < num_env_vars; ++i){
			if(env_vars[i][0] == args[1]){
				int j;
				for(j = i; j < num_env_vars; ++j){
					if(j == num_env_vars - 1){
						env_vars[j][0] = "";
						env_vars[j][1] = "";
						num_env_vars--;
						//return 1 for success?
					}
					else{
						env_vars[j][0] = env_vars[j+1][0];
						env_vars[j][1] = env_vars[j+1][1];
					}
				}
			}
		}
		printf("The variable you entered is not stored.");
		//still return 1 because instructions say ignore non-finds? still print statement?
	}

	int sh_cd(int nargs, char * args[]){
		if(nargs > 2){
			//too many args throw error
		}
		if(nargs == 1){
			//need to go to home directory
			//return 1 for success?
		}
		else{
			if (chdir(args[1]) == -1){
				//path could not be found in directory
				//return error
			}
			else{
				//changed directories successfully
				//return 1 for success?
			}
		}
	}

	int sh_alias(int nargs, char * args[]){
		if(nargs > 3){
			//too many args throw error
		}
		if(nargs < 3){
			//not enough args throw error
		}
		if(MAXALIASES == num_alias){
			//throw error; cant hold more aliases
			//return 0 for error?
		}
		else{
			char* word = args[2];
			char* word2;
			char* finalWord;
			strcpy(word2,&word[1]);
			strncpy(finalWord,word2,strlen(word2)-1);	//finalword takes off the "" from the arg
			alias[num_alias][0] = args[1];
			alias[num_alias][1] = finalWord;
			num_alias++;
			//return 1 for success?
		}
	}

	int sh_unalias(int nargs, char * args[]){
		if(nargs < 2){
			//not enough args throw error
		}
		if(nargs > 2){
			//too many args throw error
		}
		int i;
		for(i = 0; i < num_alias; ++i){
			if(alias[i][0] == args[1]){
				int j;
				for(j = i; j < num_alias; ++j){
					if(j == num_alias - 1){
						alias[j][0] = "";
						alias[j][1] = "";
						num_alias--;
						//return 1 for success?
					}
					else{
						alias[j][0] = alias[j+1][0];
						alias[j][1] = alias[j+1][1];
					}
				}
			}
		}
		printf("An alias by that name was not found.");
		//return 0 for failure?
	}
	
	int sh_aliaslist(int nargs, char * args[]){
		if(nargs > 1){
			//too many args throw error
		}
		int i;
		for(i = 0; i < num_alias; ++i){
			printf("%s\n", alias[i][0]);
		}
		//return 1 for success?
	}

	int sh_bye(int nargs, char * args[]){exit(0);}

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
		read_cmd = TRUE;
	}

%}

%token OTHER_TOK INTO_TOK FROM_TOK STDOUT_TOK STDERR_TOK BACKGROUND_TOK PIPE_TOK EOF_TOK

%%


command:
		//init_a_cmd with cmd_name = OTHER_TOK
		OTHER_TOK					{ $$ = $1; init_or_addarg($1);}
		//push arg onto argv
		| command OTHER_TOK			{ $$ = $1; init_or_addarg($2);}
		//pipe commands, increment cmd argstack to push args to correct argv later
		| command PIPE_TOK command	{ $$ = $3; init_a_cmd($3);}
		//redirecting already done, just reducing statement
		| command redirect 			{ $$ = $1;}
		//execute command in background
		| command BACKGROUND_TOK 	{ $$ = $1; run_background = TRUE;}
		//execute the commands that have been defined at end of line, then clears cmdtab
		// { $$ = $1; execute_cmds(); clear_cmds(); } is the real cmd
		| command EOF_TOK			{ $$ = $1; clear_cmds(); }
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