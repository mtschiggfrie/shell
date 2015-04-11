void errs_map(int err){
	if(err == -1) fprintf(stderr, "Not enough args.\n");
	if(err == -2) fprintf(stderr, "Too many args.\n");
	if(err == -3) fprintf(stderr, "That variable name is already in use.\n");
	if(err == -4) fprintf(stderr, "That alias name is already in use.\n");
	if(err == -5) fprintf(stderr, "Identified nested sequences of aliases.\n");
	if(err == -6) fprintf(stderr, "Max number of variables are already stored.\n");
}
