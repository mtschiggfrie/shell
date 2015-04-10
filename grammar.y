%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <unistd.h> 
	#include <string.h>
	#include <fcntl.h>
	#include <sys/types.h>
	#include <dirent.h>
	#include <sys/stat.h>
	
	#define YYSTYPE char *
	#define MAXENVVARS 10
	#define MAXALIASES 10
	#define max_pipes 5

	extern int alphasort();	//used in ls

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
		struct a_cmd * cmd = malloc(sizeof (struct a_cmd));
		if(!cmd) //throw mem error
		cmd -> cmd_name = malloc(100* sizeof (char)); //placeholder 100
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
			// printf("%s-arg\n", name); 
			add_args(name);
		}
		if(read_cmd == TRUE){
			// printf("%s-cmd\n", name); 
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
			env_vars[num_env_vars][0] = malloc(100);
			env_vars[num_env_vars][0] = args[0];		//store the variable
			env_vars[num_env_vars][1] = malloc(100);
			env_vars[num_env_vars][1] = args[1];		//store the word
			num_env_vars++;
			//return 1 for success?
		}
	}

	int sh_printenv(int nargs, char * args[]){
		if(nargs > 1){
			//too many args throw error
		}
		if(num_env_vars == 0){
			printf("You currently do not have any environmental variables.\n");
		}
		else{
			int i = 0;
			for(; i < num_env_vars; i++){
			printf("%s", env_vars[i][0]);	//prints the variable
			printf(" = ");
			printf("%s\n", env_vars[i][1]);	//prints the word
			}
		}
		//always return 1 because never fails?
	}

	int sh_unsetenv(int nargs, char * args[]){
		if(nargs > 1){
			//too many args throw error
		}
		if(nargs < 1){
			//not enough args throw error
		}
		int i;
		for(i = 0; i < num_env_vars; ++i){
		//this for loop goes through the env_vars array and breaks into the
		//if section when the given variable in args matches the current env_var
			if(!strcmp(env_vars[i][0], args[0])){
				int j;
				for(j = i; j < num_env_vars; ++j){
					if(j == num_env_vars - 1){
					//this is when last element in array (nothing after to copy)

						env_vars[j][0] = "";//delete last element (now duplicate)
						env_vars[j][1] = "";//delete last element (now duplicate)
						num_env_vars--;

						//return 1 for success?
						return 1;
					}
					else{
					//we need to move all of the variables and words up one slot
					//because we took out the old variable and word
						env_vars[j][0] = env_vars[j+1][0];
						env_vars[j][1] = env_vars[j+1][1];
					}
				}
			}
		}
		printf("The variable you entered is not stored.\n");
		//still return 1 because instructions say ignore non-finds? still print statement?
	}

	int sh_cd(int nargs, char * args[]){
		if(nargs > 1){
			//too many args throw error
		}
		if(nargs == 0){
			chdir(getenv("HOME"));

			//return 1 for success?
			return 1;
		}
		else{
		//chdir returns -1 if error, else it successfully changed directory

			
			if(!strcmp(args[0], "..")){
			// "cd .." was enterned so change directy to one up
				char *back = "..";
				chdir(back);

				return 1;
			}

			if (chdir(args[0]) == -1){
				printf("Could not change path.\n");
				//return error
			}
			else{
				printf("changed path successfully.\n");
				//return 1 for success?
			}
		}
	}

	int sh_alias(int nargs, char * args[]){
		if(nargs == 0){
			//when alias entered without args, need to pring all current aliases
			sh_aliaslist(nargs, args);
			return 1;
		}
		if(nargs > 2){
			//too many args throw error
		}
		if(nargs < 2){
			//not enough args throw error
		}
		if(MAXALIASES == num_alias){
			//throw error; cant hold more aliases
			//return 0 for error?
		}
		else{
			//storing the word (ex. "cd path") as cd path (without quotes)			

			char* finalWord = args[1] + 1;		//take off the first "
			finalWord[strlen(finalWord)-1] = 0;	//and the last "

			alias[num_alias][0] = malloc(100);
			alias[num_alias][0] = args[0];		//store name
			alias[num_alias][1] = malloc(100);
			alias[num_alias][1] = finalWord;	//store word (command)
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
		//this loop goes through each element in alias array until it matches the name to
		//the name given through the args
			if(!strcmp(alias[i][0], args[0])){
				int j;
				for(j = i; j < num_alias; ++j){
					if(j == num_alias - 1){
						alias[j][0] = "";//delete last element (now duplicate)
						alias[j][1] = "";//delete last element (now duplicate)
						num_alias--;

						//return 1 for success?
						return 1;
					}
					else{
					//this moves the elements up 1 position to fill gap of the
					//removed alias

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

		//this function prints all aliases stored in the alias array

		int i;
		for(i = 0; i < num_alias; ++i){
			printf("%s", alias[i][0]);	//prints the name
			printf(" = ");
			printf("%s\n", alias[i][1]);	//prints the word (command w/o quotes)
		}
		//return 1 for success?
	}

	int sh_bye(int nargs, char * args[]){exit(0);}

	/*********************************************/
	/* non-built-in functions
	/*********************************************/

	//this function is used to get current directory
	//should we use this with every line? like real terminals?
	int  xsh_currdir(){
		char buff[128];
		memset(buff,0,sizeof(buff));

		//getcwd = get current working directory
		//its args are a string and the size of the string

		char *curr_path = getcwd(buff,sizeof(buff));
		printf("%s\n", curr_path);
	}


	
	int xsh_ls(int nargs, char * args[]){
		//get current directory
		char buff[128];
		memset(buff,0,sizeof(buff));
		char *path = getcwd(buff,sizeof(buff));

		//count becomes number of files
		//files is a structure that holds the info on the directory's files
		struct dirent **files;
		int count;
		count = scandir(path, &files, 0, alphasort);

		int i;
		for(i = 1; i < count + 1; ++i){
			//print out each file
			printf("%s ",files[i-1]->d_name);
		}
		printf("\n");
	}

	int xsh_printtest(int nargs, char * args[]){
		printf("printing test\n");
	}

	/*********************************************/
	/*cmdmap - Maps each cmd_name to its proper 
	function */
	/*********************************************/

	fptr sh_cmdmap(char * cmd_name){
		if(!strcmp(cmd_name, "setenv")) return &sh_setenv;
		if(!strcmp(cmd_name,"printenv")) return &sh_printenv;
		if(!strcmp(cmd_name, "unsetenv")) return &sh_unsetenv;
		if(!strcmp(cmd_name, "cd")) return &sh_cd;
		if(!strcmp(cmd_name, "alias")) return &sh_alias;
		if(!strcmp(cmd_name, "unalias")) return &sh_unalias;
		if(!strcmp(cmd_name, "bye")) return &sh_bye;

		return 0;
	}

	fptr xsh_cmdmap(char * cmd_name){
		if(!strcmp(cmd_name, "printtest")) return &xsh_printtest;
		if(!strcmp(cmd_name, "ls")) return &xsh_ls;
		if(!strcmp(cmd_name, "currdir")) return &xsh_currdir;

		return 0;
	}

	/*********************************************/
	/* execute_cmds - executes each command in 
	cmdtab */
	/*********************************************/

	void execute_cmds(){
		int i;
		int pid;
		fptr a_func;
		struct a_cmd * cmd;

		for(i = 0; i < num_cmds; ++i){
			cmd = cmdtab[i];
			/* search built-ins */
			if(a_func = sh_cmdmap(cmd -> cmd_name)){
				//will only be one cmd for built-ins, set a flag after running
				a_func(cmd -> nargs, cmd -> args);
			}

			/* search non-built-ins */	
			else if(a_func = xsh_cmdmap(cmd -> cmd_name)){
				printf("!!!!!\n");
				int j;
				int * pipes[num_cmds];
				int fd;
				a_func(cmd -> nargs, cmd -> args); //using for ls testing
				
				for(j = 0; j < num_cmds; ++j){
					//create pipes, pidlist
				}

				if(file_in){
					fd = open(file_in, O_RDONLY);
					if (fd != -1){
						dup2(fd, STDIN_FILENO);
						close(fd);
					}
					else{} //couldnt read from file_in
				}

				if(file_out){
					printf("%s", file_out);
					fd = open(file_out, O_WRONLY);
					if (fd != -1){
						printf("got this far\n");
						dup2(fd, STDOUT_FILENO);
						close(fd);
						// a_func(cmd -> nargs, cmd -> args);
					}
					else{} //couldnt read from file_in
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

		for(i = 0; i < num_cmds; ++i) free(cmdtab[i-1]);  //release cmd mem for next line of input
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
		| command EOF_TOK			{ $$ = $1; execute_cmds(); clear_cmds(); }
		;

redirect:
		input_redirect { ;}
		| output_redirect { ;}
		| redirect redirect { ;} //fix allow chaining of redirects later

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
