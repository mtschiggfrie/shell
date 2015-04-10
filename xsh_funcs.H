/**************************************/
/* Implemented Non-Built-In Commands
/**************************************/
/* currdir() - prints current directory
ls(opt arg) - prints sorted subdirectories
echo(word) - prints string */
/**************************************/

extern int alphasort();	//used in ls

//this function is used to get current directory
//should we use this with every line? like real terminals?
int xsh_currdir(){
	char buff[128];
	memset(buff,0,sizeof(buff));

	//getcwd = get current working directory
	//its args are a string and the size of the string

	char *curr_path = getcwd(buff,sizeof(buff));
	printf("%s\n", curr_path);
}

int xsh_ls(int nargs, char * args[]){
	printf("here");
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

int xsh_echo(int nargs, char * args[]){
	// if(nargs > 2) return -1; //too many args
	// if(nargs <= 0) return -2; //too little args
	// printf("%s\n", args[0]);
	execv("/bin/echo", args);
}
