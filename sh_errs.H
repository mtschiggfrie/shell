void errs_map(int err){
	if(err == -1) fprintf(stderr, "Not enough args. line no %d\n", __LINE__);
	if(err == -2) fprintf(stderr, "Too many args. line no %d\n", __LINE__);
	if(err == -3) fprintf(stderr, "That variable name is already in use. line no %d\n", __LINE__);
	if(err == -4) fprintf(stderr, "That alias name is already in use. line no %d\n", __LINE__);
	if(err == -5) fprintf(stderr, "Identified nested sequences of aliases. line no %d\n", __LINE__);
	if(err == -6) fprintf(stderr, "Max number of variables are already stored. line no %d\n", __LINE__);
}
