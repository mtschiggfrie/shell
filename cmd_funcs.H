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

/*********************************************/
/* Setters */
/*********************************************/
void run_in_background(){run_background = TRUE;}
void set_file_in(char * file_in){file_in = file_in;}
void set_file_out(char * file_out){file_out = file_out;}
void do_append(){append = TRUE;}

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
	if(!strcmp(cmd_name, "echo")) return &xsh_echo;
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