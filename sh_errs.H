char * errs_map(int err){
	//arg errors subset of syntax errors
	if(err = -1) return "Not enough args";
	if(err = -2) return "Too many args";
	if(err = -3) return "That variable name is already in use";
	if(err = -4) return "That alias name is already in use";
	if(err = -5) return "Identified nested sequences of aliases";
}