%{

#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
extern YYSTYPE yylval;
int end_shell = 0;

%}

%%
\"[ A-Za-z_0-9\\\/]*\"           { yylval = strdup(yytext); return OTHER_TOK; }
"\>"                             { return INTO_TOK;  }
"<"                              { return FROM_TOK;  }
"|"                              { return PIPE_TOK;  }
"&"                              { return BACKGROUND_TOK; }
"2"                              { return STDERR_TOK;  }
"&1"                             { return STDOUT_TOK;  }
"bye"							 { end_shell = 1; return;}
[A-Za-z0-9]+"\."[A-Za-z_0-9]+    { yylval = strdup(yytext); return OTHER_TOK;  }
[A-Za-z0-9\\\/]+                 { yylval = strdup(yytext); return OTHER_TOK;  }
\n                               { return EOF_TOK;  }
[ \t]                          {}
.                                {}
%%

int main(void)
{
int tok = 1;
    do {
    	if(end_shell == 1) break;
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