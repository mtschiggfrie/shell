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
	//array to return
	char * array[50];
	int arraynumber = 0;

	//get current directory
	char buff[128];
	memset(buff,0,sizeof(buff));
	char *path = getcwd(buff,sizeof(buff));

	//count becomes number of files
	//files is a structure that holds the info on the directory's files
	struct dirent **files;
	int count;
	count = scandir(path, &files, 0, alphasort);

 	//this splits the arg into word(filename) and the extension(after the last .)
	int index;
	char * e = strrchr(args[0],'.');
	index = (int)(e - args[0]);
	char * word = args[0];
	word[index] = '\0';
	char * extension = word+index+1;


	index = 2; //skip the . and ..
	for(; index < count; ++index){
	//each file in the current directory

	
	//these lines split the given file into its filename and extension
	int index2;
	char * fullfile = malloc(30);
	char * newfile = files[index]->d_name;
	strcpy(fullfile,newfile);
	e = strrchr(newfile,'.');
	if(e != NULL){
	index2 = (int)(e - newfile);
	char * currentfile = newfile;	
	currentfile[index2] = '\0';
	char * currentextension = currentfile+index2+1;

	
	int boolNumber = 1;//changes to 0 when need to break from while loop
	int success = 0;//0 means not a filename match/1 filename matched
	int i = 0;//i and j will go through each char in filename from arg and the current filename
	int j = 0;
	while(boolNumber == 1){
		if((word[i] == '\0' || word[i+1] == '\0') && currentfile[j] == '\0'){
			//this is called when both reach the end of the string
			//means it made it through without a conflict(not a char match)
			//so break from while and make success 1
			boolNumber = 0;
			success = 1;
		}
		else if(word[i] == '\0' || currentfile[j] == '\0'){
			//if one reaches the end before the other, obviously no match... break while
			boolNumber = 0;
		}
		else if(word[i] == currentfile[j]){
			//when 2 chars match go onto next
			i++;
			j++;
		}
		else if(word[i] == '*'){
			//if its a *, that means it can match any char
			if(word[i+1] == currentfile[j]){
				//if the char after * matches the current char, move past the *
				//for exp...  *mp    hmp  obviously * only needed for h
				i = i + 2;
			}
			j++;
		}
		else if(word[i] != currentfile[j]){
			//a missmatch between chars means no match
			boolNumber = 0;
		}
	}
	if(success == 1){
	//if the filenames match, we need to check the extension now
		//reset values to use in traversing the strings
		boolNumber = 1;
		success = 0;
		i = 0;
		j = 0;

		while(boolNumber == 1){
		//this is same as above, success = 1 means that the extension matchs the current file's
			if((extension[i] == '\0' || extension[i+1] == '\0') && currentextension[j] == '\0'){
				boolNumber = 0;
				success = 1;
			}
			else if(extension[i] == '\0' || currentextension[j] == '\0'){
				boolNumber = 0;
			}
			else if(extension[i] == currentextension[j]){
				i++;
				j++;
			}
			else if(extension[i] == '*'){
				if(extension[i+1] == currentextension[j]){
					if(extension[i+2] == currentextension[j+1]){
						i = i + 2;
					}
				}
				j++;
			}
			else if(extension[i] != currentextension[j]){
				boolNumber = 0;
			}
		}
		
		if(success == 1){
			//the current filename and extension match that of the arg so add it to array

			array[arraynumber++] = fullfile;
		}
	}
	}
	}
	int k = 0;
			printf("\n");
		for(; k < arraynumber; ++k){
	printf("%s\n",array[k]);
	}
	return 1;

}

int xsh_echo(int nargs, char * args[]){
	// if(nargs > 2) return -1; //too many args
	// if(nargs <= 0) return -2; //too little args
	// printf("%s\n", args[0]);
	execv("/bin/echo", args);
}
