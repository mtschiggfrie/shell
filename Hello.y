%{

	#include <stdio.h>
	#include <stdlib.h>
	
%}

%token CD FILENAME PATH EXIT LIST COPY MOVE REMOVE LINK MAKEDIR TRANSFER TRANSFERG CHANGEPERM REMOVEDIR FIND

%%

command: 
         cd|filename|path|exit|list|copy|move|remove|link|makedir|transfer|transferg|changeperm|removedir|find
        ;
		
cd:
		CD	   { printf("CD\n");	}
		;
filename:
		FILENAME	   { printf("FILENAME\n");	}
		;
path:
		PATH	   { printf("PATH\n");	}
		;
exit:
		EXIT	   { printf("Goodbye\n"); exit(0);	}
		;
list:
		LIST	   { printf("LS\n");	}
		;
copy:
		COPY	   { printf("CP\n");	}
		;	
move:
		MOVE	   { printf("MV\n");	}
		;	
remove:
		REMOVE	   { printf("RM\n");	}
		;	
link:
		LINK	   { printf("LN\n");	}
		;	
makedir:
		MAKEDIR	   { printf("MKDIR\n");	}
		;	
transfer:
		TRANSFER	   { printf("CHOWN\n");	}
		;	
transferg:
		TRANSFERG	   { printf("CHGRP\n");	}
		;	
changeperm:
		CHANGEPERM	   { printf("CHMOD\n");	}
		;	
removedir:
		REMOVEDIR	   { printf("RMDIR\n");	}
		;	
find:
		FIND	   { printf("FIND\n");	}
		;	
																				
		
		