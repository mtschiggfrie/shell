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

char * alias[MAXALIASES][2];  		 //alias[0][0] = name of alias and alias[0][1] = the cmd in a string
int num_alias = 0;

int prepend_currdir(){
	char buff[128];
	memset(buff,0,sizeof(buff));
	char *curr_path = getcwd(buff,sizeof(buff));
	printf("%s: ", curr_path);
}

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
		return 1;
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

int sh_bye(int nargs, char * args[]){
	printf("exiting shell!\n");
	exit(0);
}
