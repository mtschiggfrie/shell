%{

#include <stdlib.h>
#include "y.tab.h"

%}

%%
"bye"							 { return OTHER_TOK; }
[A-Za-z0-9]+"\."[A-Za-z_0-9]+    { return DUMMY_TOK;  }
[A-Za-z0-9\\\/]+                 { return DUMMY_TOK;  }
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