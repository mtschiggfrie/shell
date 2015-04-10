#define max_pipes 5

typedef enum { FALSE, TRUE } bool;
typedef int(*fptr)(int, char const*[]);

struct a_cmd {
	char * cmd_name;
	int nargs;
	char const * args[];
};

char * file_out;	//Redirect STDOUT of final command to file_out
char * file_in;		//Redirect STDIN of final command to file_in
bool append = FALSE;//Redirect and append STDOUT of final command to file_out
bool run_background = FALSE;//Default is to wait for cmds to finish executing

bool read_cmd = TRUE;//Flag for init_or_addarg to decide which function to call on reading OTHER_TOK

int sh_STDIN, sh_STDOUT;//For restoring STDIN, STDOUT after redirects
bool changed_file_in, changed_file_out;//Flags for restoring STDIN, STDOUT after cmd execution

struct a_cmd * cmdtab[max_pipes];
int num_cmds = 0;

/*********************************************/
/* Setters */
/*********************************************/
void run_in_background(){run_background = TRUE;}
void set_file_in(char * file){file_in = file;}
void set_file_out(char * file){file_out = file;}
void do_append(){append = TRUE;}

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
	if(!strcmp(cmd_name, "echo")) return "/bin/echo";
	if(!strcmp(cmd_name, "ls")) return "/bin/ls";
	if(!strcmp(cmd_name, "pwd")) return "/bin/pwd";

	return 0;
}

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
	cmd -> nargs = 1;
	cmdtab[num_cmds++] = cmd;
	read_cmd = FALSE;

	/* if non-built-in command, initialize args with cmd location */
	char * xsh_func_loc;
	if(xsh_func_loc = xsh_cmdmap(cmd_name)){
		(cmd -> args)[0] = xsh_func_loc;
	}
}

void add_args(char * arg){
	struct a_cmd * cmd = cmdtab[num_cmds - 1]; //current command
	(cmd -> args)[(cmd -> nargs)] = malloc(sizeof(char*) * 100);
	(cmd -> args)[(cmd -> nargs)++] = arg;	//add arg into cmd's args, increment nargs
}

void init_or_addarg(char * name){
	if(read_cmd == FALSE) add_args(name);
	else init_a_cmd(name);
}

void read_cmd_next(){ read_cmd = TRUE; }

/*********************************************/
/* redirect_input, redirect_output */
/*********************************************/

int redirect_input(char * file_in){
	int fd;
	fd = open(file_in, O_RDONLY);
	if (fd != -1){
		sh_STDIN = dup(STDIN_FILENO);
		dup2(fd, STDIN_FILENO);
		close(fd);
		changed_file_in = TRUE;
	}
	else{} //couldnt read from file_in
}

int redirect_output(char * file_out){
	int fd;
	fd = open(file_out, O_WRONLY);
	if (fd != -1){
		sh_STDOUT = dup(STDOUT_FILENO);
		dup2(fd, STDOUT_FILENO);
		close(fd);
		changed_file_out = TRUE;
	}
	else{} //couldnt read from file_in
}	

/*********************************************/
/* execute_cmds - executes each command in 
cmdtab */
/*********************************************/

void execute_cmds(){
	int i;
	pid_t pid;
	fptr sh_func;
	char * xsh_func_loc;
	struct a_cmd * cmd;

	if(num_cmds == 0) return;
		
	cmd = cmdtab[0];

	/* search built-ins */
	if(sh_func = sh_cmdmap(cmd -> cmd_name)){
		sh_func(cmd -> nargs, cmd -> args);	//run matched sh_func
	}

	/* search non-built-ins */	
	else if(xsh_func_loc = xsh_cmdmap(cmd -> cmd_name)){
		int pipes[num_cmds][2];
		pid_t pid_list[num_cmds];
		int fd;
		int j, k, l;

		char * xsh_func_args[cmd -> nargs]; //max_commands = 10
		// xsh_func_args[0] = (char *)(cmd -> args)[0];
		// xsh_func_args[1] = (char *)(cmd -> args)[1];
		for(j = 0; j < cmd -> nargs; ++j) xsh_func_args[j] = (char *)(cmd -> args)[j];
		xsh_func_args[cmd -> nargs] = (char *){'\0'};

		/* If only one command entered */
		if(num_cmds == 1){
			pid_list[0] = fork();
			if(pid_list[0] == 0){
				if(file_in) redirect_input(file_in);
				if(file_out) redirect_output(file_out);
				execv((char *)xsh_func_loc, xsh_func_args);
				exit(0);
			}
		}

		/* If we are pipelining */
		// else {
		// 	/* Create pipes */	
		// 	for(j = 0; j < num_cmds; ++j) pipe(pipes[j]);

		// 	/* For cmd in cmdtab */
		// 	for(j = 0; j < num_cmds; ++j){
		// 		pid_list[j] = fork();

		// 		/* If the child */
		// 		if(pid_list[j] == 0){
		// 			dup2(pipes[j][0], STDIN_FILENO);	//proccess j+1 reads from j
		// 			dup2(pipes[j+1][1], STDOUT_FILENO); //process j+1 writes to j+2

		// 			for(k = 0; k < num_cmds; ++k){
		// 				for(l = 0; l < 2; ++l){
		// 					close(pipes[j][l]);
		// 				}
		// 			}
		// 			// sh_func(cmd -> nargs, cmd -> args);
		// 			// execv("/bin/echo", cmd -> args);
		// 			//execute cmd
		// 			exit(0);
		// 		}
		// 	}

		// 	/* Close pipes for parent */
		// 	for(k = 0; k < num_cmds; ++k){
		// 		for(l = 0; l < 2; ++l){
		// 			close(pipes[j][l]);
		// 		}
		// 	}
		// }

		/* If run_backround then wait for child processes to terminate */
		if(run_background = TRUE){
			for(j = 0; j < num_cmds; ++j) wait();
		}

		/* Test pipe code *//*
		pipe_list = {int pipe_12[2], pipe_23[2], ..., pipe_(n-1)n[2]}
		pid_list = {int pid_1, pid_2, ..., pid_n}

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
		*/
	}
	
	else{
		printf("No such cmd: %s\n", cmd -> cmd_name);
	}
}

void clear_cmds(){
	int i;

	/* release cmd mem for next line of input */
	for(i = 0; i < num_cmds; ++i) free(cmdtab[i-1]);

	/* restore STDIN, STDOUT */
	if(changed_file_in == TRUE){
		dup2(sh_STDIN, STDIN_FILENO);
		close(sh_STDIN);
	}
	if(changed_file_out == TRUE){
		dup2(sh_STDOUT, STDOUT_FILENO);
		close(sh_STDOUT);
	}

	/* reset defaults */
	num_cmds = 0; file_in = 0; file_out = 0;
	append = FALSE; run_background = FALSE;
	read_cmd = TRUE;
	changed_file_in = FALSE, changed_file_out = FALSE;
}

