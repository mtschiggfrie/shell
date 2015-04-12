void errs_map(int err){
	//arg errors subset of syntax errors
	if(err == -1) printf("Not enough args.\n");
	if(err == -2) printf("Too many args.\n");
	if(err == -3) printf("That variable name is already in use.\n");
	if(err == -4) printf("That alias name is already in use.\n");
	if(err == -5) printf("Identified nested sequences of aliases.\n");
	if(err == -6) printf("Max number of variables are already stored.\n");
}
