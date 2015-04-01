%{

#include <stdlib.h>
#include "y.tab.h"

%}

%%
"exit"                           { return EXIT; }
"ls"                             { return LIST; }
"cp"                             { return COPY; }
"mv"                             { return MOVE; }
"rm"                             { return REMOVE; }
"ln"                             { return LINK; }
"mkdir"                          { return MAKEDIR; }
"chown"                          { return TRANSFER; }
"chgrp"                          { return TRANSFERG; }
"chmod"                          { return CHANGEPERM; }
"rmdir"                          { return REMOVEDIR; }
"find"                           { return FIND; }
"cd"                             { return CD;  }
[A-Za-z0-9]+"\."[A-Za-z_0-9]+     { return FILENAME;  }
[A-Za-z0-9\\\/]+                 { return PATH;  }
[ \t\n]           {}
%%

int main(void)
{
int tok = 1;
    do {
		tok = yyparse();
    } while (1);
    return 0;
}

int yywrap(void)
{
    return 0;
}

int yyerror(void)
{
    printf("Error\n");

}