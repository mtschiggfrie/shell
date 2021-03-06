/*****************************************************************/
/*Implemented Built-In Commands
/*****************************************************************/
/* prepend_currdir() - internal, prepends currdir prior to command entering 
setenv(variable, word) - sets variable to word
printenv() - prints env variables
cd(dir) - change directory
alias(name, word) - makes an alias called name with command word
unalias(name) - removes alias called name
bye() - prints msg and exits*/

/*****************************************************************/

#define MAXENVVARS 10
#define MAXALIASES 10

char * env_vars[MAXENVVARS][2];  //env_vars[0][0] = variable and env_vars[0][1] = word
int num_env_vars = 0;

char * prev_path = NULL;		//previous path.... used in cd -

char * alias[MAXALIASES][2];  		 //alias[0][0] = name of alias and alias[0][1] = the cmd in a string
int num_alias = 0;

int prepend_currdir(){
	char buff[128];
	memset(buff,0,sizeof(buff));
	char *curr_path = getcwd(buff,sizeof(buff));
	printf("%s: ", curr_path);
}

char * sh_aliasmap(char * a_name){
	int i;
	for(i = 0; i < num_alias; ++i){
		if(!strcmp(a_name, alias[i][0])){
			return alias[i][0];
		}
	}
	return 0;
}

int sh_setenv(int nargs, char * args[]){

	if(nargs > 2){
		errs_map(-2);
		return 0;
	}
	if(nargs < 2){
		errs_map(-1);
		return 0;
	}
	if(MAXENVVARS == num_env_vars){
		errs_map(-6);
		return 0;
	}
		
	int i;
	for(i = 0; i < num_env_vars; ++i){
		if(!strcmp(env_vars[i][0],args[0])){
			errs_map(-3);
			return 0;
		}
	}

	env_vars[num_env_vars][0] = malloc(100);
	env_vars[num_env_vars][0] = args[0];		//store the variable
	env_vars[num_env_vars][1] = malloc(100);
	env_vars[num_env_vars][1] = args[1];		//store the word
	num_env_vars++;
	return 1;
}

int sh_printenv(int nargs, char * args[]){
	if(nargs > 1){
		errs_map(-2);
		return 0;
	}
	if(num_env_vars == 0){
		fprintf(stderr, "You currently do not have any variables. Line no %d\n", __LINE__);
	}
	else{
		int i = 0;
		for(; i < num_env_vars; i++){
		printf("%s", env_vars[i][0]);	//prints the variable
		printf(" = ");
		printf("%s\n", env_vars[i][1]);	//prints the word
		}
	}
	return 1;
}

int sh_unsetenv(int nargs, char * args[]){
	if(nargs > 1){
		errs_map(-2);
	}
	if(nargs < 1){
		errs_map(-1);
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
	fprintf(stderr, "The variable you entered is not stored. Line no %d\n", __LINE__);
	return 1;
}

int sh_cd(int nargs, char * args[]){
	if(prev_path == NULL) prev_path = xsh_currdir();

	if(nargs > 1){
		//doesnt matter
	}

	if(nargs == 0){
		prev_path = xsh_currdir();
		chdir(getenv("HOME"));

		return 1;
	}


	char * start = strchr(args[0],'/');
	if(args[0][0] == '/' && args[0][1] == '\0'){
		prev_path = xsh_currdir();
		chdir(start);
		return 1;
	}
	if(start != NULL){
	//this splits the arg at the first / and then recursively calls the first and second part
		char * tmp = malloc(100);
		prev_path = xsh_currdir();
		strcpy(tmp,prev_path);

		int index;
		index = (int)(start - args[0]);
		char * first[1];
		first[0] = malloc(30);	//first[0] is the part in front of the first /
		first[0] = args[0];
		first[0][index] = '\0';
		char * second[1];	//second[0] is the part behind the first /
		second[0] = malloc(30);
		second[0] = args[0]+index+1;

		sh_cd(1,first);
		sh_cd(1,second);

		prev_path = tmp;
		return 1;
	}
	
	if(!strcmp(args[0], "..")){
	// "cd .." was enterned so change directy to one up
		//char *back = "..";
		prev_path = xsh_currdir();
		chdir("..");
		return 1;
	}
	if(!strcmp(args[0], ".")){
		prev_path = xsh_currdir();
	//	printf("%s\n",prev_path);
		return 1;
	}
	if(!strcmp(args[0], "-")){
		char * tmp = malloc(100);
		strcpy(tmp,prev_path);
		prev_path = xsh_currdir();
		chdir("/");
	//	printf("%s\n",tmp);
		chdir(tmp);
		return 1;
	}

	prev_path = xsh_currdir();
	if (chdir(args[0]) == -1){
		fprintf(stderr, "Could not change path. Line no %d\n", __LINE__);
		return 0;
	}
	else{
		return 1;
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
		errs_map(-2);
		return 0;
	 }
	 if(nargs < 2){
	 	//not enough args throw error
		errs_map(-1);
		return 0;
	 }

	int i;
	for(i = 0; i < num_alias; ++i){
		if(!strcmp(alias[i][0],args[0])){
			errs_map(-4);
			return 0;
		}
	}
	
	if(MAXALIASES == num_alias){
	 	fprintf(stderr, "can't hold any more aliases at line no %d\n", __LINE__);
	 	return 0;
	}
	char* finalWord;
	finalWord = args[1];	//we dont need to remove quotes
 	alias[num_alias][0] = malloc(100);
 	alias[num_alias][0] = args[0];		//store name
 	alias[num_alias][1] = malloc(100);
		alias[num_alias][1] = finalWord;	//store word (command)

		/* print alias to a file which is read from to execute the alias */
 	FILE *fp;
 	fp = fopen(alias[num_alias][0], "w");
 	if(fp){	
		fprintf(fp, "%s", finalWord);
		fclose(fp);

		num_alias++;
	}
	else{ 
		fprintf(stderr, "failed to open aliasfile at line no %d", __LINE__);
		return 0;
	}
	
	return 1;
}

int sh_unalias(int nargs, char * args[]){
	if(nargs < 1){
		errs_map(-1);
		return 0;
	}
	if(nargs > 1){
		errs_map(-2);
		return 0;
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
	fprintf(stderr, "An alias by that name was not found. Line no %d\n", __LINE__);
	return 0;
}

int sh_aliaslist(int nargs, char * args[]){
	//this function prints all aliases stored in the alias array

	int i;
	// printf("%d - num_alias", num_alias);
	for(i = 0; i < num_alias; ++i){
		printf("%s", alias[i][0]);	//prints the name
		printf(" = ");
		printf("%s\n", alias[i][1]);	//prints the word (command w/o quotes)
		//return 1 for success?
	}
	if(num_alias == 0) fprintf(stderr, "No aliases are currently stored. Line no %d\n", __LINE__);
	return 0;
}

int sh_bye(int nargs, char * args[]){
	printf("exiting shell!\n");
	exit(0);
}
