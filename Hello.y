%{

	#include <stdio.h>
	#include <stdlib.h>
	
%}

%token CD FILENAME PATH EXIT LIST COPY MOVE REMOVE LINK MAKEDIR TRANSFER TRANSFERG CHANGEPERM REMOVEDIR FIND

%%

commands:
		command | commands command
		;
command: 
         cd|filename|path|exit|list|copy|move|remove|link|makedir|transfer|transferg|changeperm|removedir|find
        ;
		
cd:
		CD	   { printf("CD ");	}
		;
filename:
		FILENAME	   { printf("FILENAME ");	}
		;
path:
		PATH	   { printf("PATH ");	}
		;
exit:
		EXIT	   { printf("Goodbye "); exit(0);	}
		;
list:
		LIST	   { printf("LS ");	}
		;
copy:
		COPY	   { printf("CP ");	}
		;	
move:
		MOVE	   { printf("MV ");	}
		;	
remove:
		REMOVE	   { printf("RM ");	}
		;	
link:
		LINK	   { printf("LN ");	}
		;	
makedir:
		MAKEDIR	   { printf("MKDIR ");	}
		;	
transfer:
		TRANSFER	   { printf("CHOWN ");	}
		;	
transferg:
		TRANSFERG	   { printf("CHGRP ");	}
		;	
changeperm:
		CHANGEPERM	   { printf("CHMOD ");	}
		;	
removedir:
		REMOVEDIR	   { printf("RMDIR ");	}
		;	
find:
		FIND	   { printf("FIND ");	}
		;	
																				
		
		