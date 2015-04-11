#define max_pipes 5
#define MAXENVVARS 10

typedef enum { FALSE, TRUE } bool;
typedef int(*fptr)(int, char *[]);

extern int num_env_vars;
extern char * env_vars[MAXENVVARS][2];

struct a_cmd {
	char * cmd_name;
	int nargs;
	// char * args[];
	char * args[1000];
};

char * file_out;	//Redirect STDOUT of final command to file_out
char * file_in;		//Redirect STDIN of final command to file_in
char * file_err;	//Redirect STDERR of final command to file_err
bool append = FALSE;//Redirect and append STDOUT of final command to file_out
bool run_background = FALSE;//Default is to wait for cmds to finish executing

bool read_cmd = TRUE;//Flag for init_or_addarg to decide which function to call on reading OTHER_TOK

int sh_STDIN, sh_STDOUT, sh_STDERR;//For restoring STDIN, STDOUT after redirects
bool changed_file_in, changed_file_out, changed_file_err;//Flags for restoring STDIN, STDOUT after cmd execution

struct a_cmd * cmdtab[max_pipes];//holds all commands, > 1 if piping
int num_cmds = 0;

/* Used by init_or_addarg to handle aliasing */

typedef struct yy_buffer_state * YY_BUFFER_STATE;
extern int yyparse();
extern YY_BUFFER_STATE yy_create_buffer(FILE *, size_t);
extern void yypush_buffer_state ( YY_BUFFER_STATE buffer );

/*********************************************/
/* Setters */
/*********************************************/
void run_in_background(){run_background = TRUE;}
void set_file_in(char * file){file_in = file;}
void set_file_out(char * file){file_out = file;}
void set_file_err(char * file){file_err = file;}
void do_append(){append = TRUE;}
void read_cmd_next(){ read_cmd = TRUE; }

/*********************************************/
/*cmdmaps - Map each cmd_name to its proper 
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

char * xsh_cmdmap(char * cmd_name){
	if(!strcmp(cmd_name, "cat")) return "/bin/cat";
	if(!strcmp(cmd_name, "chgrp")) return "/bin/chgrp";
	if(!strcmp(cmd_name, "chown")) return "/bin/chown";
	if(!strcmp(cmd_name, "cp")) return "/bin/cp";
	if(!strcmp(cmd_name, "dir")) return "/bin/dir";
	if(!strcmp(cmd_name, "echo")) return "/bin/echo";
	if(!strcmp(cmd_name, "grep")) return "/bin/grep";
	if(!strcmp(cmd_name, "kill")) return "/bin/kill";
	if(!strcmp(cmd_name, "ls")) return "/bin/ls";
	if(!strcmp(cmd_name, "mkdir")) return "/bin/mkdir";
	if(!strcmp(cmd_name, "more")) return "/bin/more";	
	if(!strcmp(cmd_name, "ps")) return "/bin/ps";
	if(!strcmp(cmd_name, "pwd")) return "/bin/pwd";
	if(!strcmp(cmd_name, "rm")) return "/bin/rm";
	if(!strcmp(cmd_name, "rmdir")) return "/bin/rmdir";
	if(!strcmp(cmd_name, "which")) return "/bin/which";

	if(!strcmp(cmd_name, "clear")) return "/usr/bin/clear";
	if(!strcmp(cmd_name, "man")) return "/usr/bin/man";
	if(!strcmp(cmd_name, "sort")) return "/usr/bin/sort";
	if(!strcmp(cmd_name, "wc")) return "/usr/bin/wc";

	return 0;
}

/*********************************************/
/* sub_env_var -

/* init_a_cmd - Initializes a_cmd with given 
cmd_name Then pushes the cmd into next free 
cmdtab */

/* add_args - adds arg to most recently read 
cmd in cmdtab */

/* init_or_addarg - chooses which f to call */
/*********************************************/

char* sub_env_var(char * name){
	char * word = malloc(25);
	word = name + 2;
	word[strlen(word)-1] = 0;	
	int i;
	for(i = 0; i < num_env_vars; ++i){
		/* checks to see if the name matches an env var and if does, return the word associated with it */
		if(!strcmp(word, env_vars[i][0])){
			word = env_vars[i][1];
			return word;
		}
	}
	/* no env var found, return error */
	return name;
}

void init_a_cmd(char * cmd_name){
	struct a_cmd * cmd = malloc(sizeof (struct a_cmd));
	if(!cmd) //throw mem error
	cmd -> cmd_name = malloc(100* sizeof (char)); //placeholder 100
	cmd -> cmd_name = cmd_name;
	cmd -> nargs = 0;
	cmdtab[num_cmds++] = cmd;
	read_cmd = FALSE;

	/* if non-built-in command, initialize args with cmd location */
	char * xsh_func_loc;
	if(xsh_func_loc = xsh_cmdmap(cmd_name)){
		(cmd -> args)[0] = xsh_func_loc;
		cmd -> nargs = 1;
	}
}

void add_args(char * const arg){
	struct a_cmd * cmd = cmdtab[num_cmds - 1]; //current command
	if(strchr(arg,'*') != NULL){
		char ** newarray;
		newarray = xsh_ls(1,arg);
		int i;
		for(i = 0; i < arraynumber; ++i){
			(cmd -> args)[(cmd -> nargs)] = malloc(sizeof(char*) * 100);
			(cmd -> args)[(cmd -> nargs)++] = newarray[i];	
		}
	}
	else{
		(cmd -> args)[(cmd -> nargs)] = malloc(sizeof(char*) * 100);
		(cmd -> args)[(cmd -> nargs)++] = arg;	//add arg into cmd's args, increment nargs
	}
}

void init_or_addarg(char * name){
	char * alias_val;
	if(alias_val = sh_aliasmap(name)){
		/* if calling unalias, dont transform alias var */
		if(num_cmds > 0 && !strcmp(cmdtab[0] -> cmd_name, "unalias")){
			add_args(name);
			return;
		}

		FILE * fp = fopen(alias_val, "r");
		if(fp){
			YY_BUFFER_STATE new_state = yy_create_buffer(fp, 100);
			yypush_buffer_state(new_state);
			yyparse();	
			fclose(fp);
		}
		else{fprintf(stderr, "%s couldn't open alias file\n", alias_val);}
	}

	else if(read_cmd == FALSE) add_args(name);
	else init_a_cmd(name);
}

/*********************************************/
/* redirect_input, redirect_output */
/*********************************************/

void save_input_redirect(){
	sh_STDIN = dup(STDIN_FILENO);
	changed_file_in = TRUE;
}

void save_output_redirect(){
	sh_STDOUT = dup(STDOUT_FILENO);
	changed_file_out = TRUE;
}

void save_err_redirect(){
	sh_STDERR = dup(STDERR_FILENO);
	changed_file_err = TRUE;
}

void restore_input_redirects(){
	if(changed_file_in == TRUE){
		dup2(sh_STDIN, STDIN_FILENO);
		close(sh_STDIN);
		changed_file_in = FALSE;
	}
}

void restore_output_redirects(){
	if(changed_file_out == TRUE){
		dup2(sh_STDOUT, STDOUT_FILENO);
		close(sh_STDOUT);
		changed_file_out = FALSE;
	}
}

void restore_err_redirects(){
	if(changed_file_err == TRUE){
		dup2(sh_STDERR, STDERR_FILENO);
		close(sh_STDERR);
		changed_file_err = FALSE;
	}
}

void restore_redirects(){
	restore_output_redirects();
	restore_input_redirects();
	restore_err_redirects();
	file_in = 0; file_out = 0; file_err = 0;
}

int redirect_input(char * file_in){
	int fd;
	fd = open(file_in, O_RDONLY);
	if (fd != -1){
		save_input_redirect();
		dup2(fd, STDIN_FILENO);
		close(fd);
	}
	else{
		fprintf(stderr, "%s file wasn't found\n", file_in);
		return -1;
	}
	return 0;
}

int redirect_output(char * file_out){
	int fd;

	if(append){
		fd = open(file_out, O_WRONLY | O_APPEND);
	}
	else{
		fd = open(file_out, O_WRONLY);
	}
	
	if (fd != -1){
		save_output_redirect();
		dup2(fd, STDOUT_FILENO);
		close(fd);
	}
	else{
		fprintf(stderr, "%s file wasn't found\n", file_out);
		return -1;
	}
	return 0; 
}	

int redirect_err(char * file_err){
	int fd;
	fd = open(file_err, O_WRONLY);
	if (fd != -1){
		save_err_redirect();
		dup2(fd, STDERR_FILENO);
		close(fd);
	}
	else{
		fprintf(stderr, "%s file wasn't found\n", file_err);
		return -1;
	}
	return 0;
}

void stderr_to_stdout(){
	save_err_redirect();
	dup2(STDERR_FILENO, STDOUT_FILENO);
}

/*********************************************/
/* execute_cmds - executes each command in 
cmdtab */
/*********************************************/

void execute_cmds(){
	pid_t pid;
	fptr sh_func;
	char * xsh_func_loc;
	struct a_cmd * cmd;
	int j, k;
	int ret;

	if(num_cmds == 0) return;
		
	cmd = cmdtab[0];

	/* search built-ins */
	if(sh_func = sh_cmdmap(cmd -> cmd_name)){
		if(num_cmds > 1){
			fprintf(stderr, "err: Tried to pipe built-ins\n");
			return;
		}
		sh_func(cmd -> nargs, cmd -> args);	//run matched sh_func
		return;
	}

	/* search non-built-ins */	
	else if(xsh_func_loc = xsh_cmdmap(cmd -> cmd_name)){
		/* perform redirects */
		if(file_err){
			if(redirect_err(file_err) == -1) return;
		}
		if(file_in){
			if(redirect_input(file_in) == -1) return;
		}
		if(file_out){
			if(redirect_output(file_out) == -1) return;
		}

		/* If only one command entered */
		if(num_cmds == 1){
			pid = fork();
			if(pid == 0){
				execv((char *)xsh_func_loc, (char * const *)(cmd -> args));
				exit(0);
			}
			if(pid < 0){
				fprintf(stderr, "error creating process\n");
				return;
			}
			if(run_background == FALSE) wait();
		}

		/* If we are pipelining */
		else {
			pid_t pid_list[num_cmds];
			int reading[num_cmds];
			int writing[num_cmds];

			/* create pipes */
			for(j = 0; j < num_cmds - 1; ++j){
				int a_pipe[2];
				pipe(a_pipe) == -1;
				reading[j+1] = a_pipe[0];
				writing[j] = a_pipe[1];
			}

			/* For cmd in cmdtab */
			for(j = 0; j < num_cmds; ++j){
				cmd = cmdtab[j];

				/* search non-built-ins */
				if(xsh_func_loc = xsh_cmdmap(cmd -> cmd_name)){
					pid_list[j] = fork();

					/* If the child */
					if(pid_list[j] == 0){
						/* if there is a prev cmd read from pipe j*/
						if( j > 0){
							close(STDIN_FILENO);
							dup2(reading[j], STDIN_FILENO);
						}
						else{}

						/* if there is a next cmd write to pipe j*/
						if(j < num_cmds - 1){
							close(STDOUT_FILENO);
							dup2(writing[j], STDOUT_FILENO);
						}
						else{}

						execv((char *)xsh_func_loc, (char * const *)(cmd -> args));
						exit(0);
					}
					if(pid_list[j] < 0){
						fprintf(stderr, "error creating process\n");
					}
					if(run_background == FALSE) wait();
					if( j > 0) close(reading[j]);
					if( j < num_cmds - 1) close(writing[j]);
				}
				else{
					fprintf(stderr, "No such cmd or trying to pipeline built-in with: %s\n", cmd -> cmd_name);
					return;
				}			
			}
		}
	}
	
	else{
		fprintf(stderr, "No such cmd: %s\n", cmd -> cmd_name);
	}
}

void clear_cmds(){
	int i;

	/* release cmd mem for next line of input */
	for(i = 0; i < num_cmds; ++i) free(cmdtab[i-1]);
	
	for(i = 0; i < arraynumber; ++i) free(array[i]);

	/* restore STDIN, STDOUT */
	restore_redirects();

	/* reset defaults */
	num_cmds = 0; arraynumber = 0;
	append = FALSE; run_background = FALSE;
	read_cmd = TRUE;
}

