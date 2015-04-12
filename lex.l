%{

#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

char * remove_quotes(char * arg){
	arg = arg + 1;
	arg[strlen(arg) - 1] = 0;
	return arg;
}

%}

%%
\"[ -.&\$|A-Za-z_0-9\\\/\><]*\"           { yylval = remove_quotes(strdup(yytext)); return QUOTE_TOK; }
^\$\{[ A-Za-z_0-9\\\/]*\}	 { yylval = strdup(yytext); return ENVVAR_TOK;}
"\>"                             { return INTO_TOK;  }
"<"                              { return FROM_TOK;  }
"|"                              { return PIPE_TOK;  }
"&"                              { return BACKGROUND_TOK; }
"2"                              { return STDERR_TOK;  }
"&1"                             { return STDOUT_TOK;  }
[A-Za-z0-9]+"\."[A-Za-z_0-9]+    { yylval = strdup(yytext); return OTHER_TOK;  }
[-.*_A-Za-z0-9\\\/]+               { yylval = strdup(yytext); return OTHER_TOK;  }
\n                               { return EOF_TOK;  }
[ \t]                          	 {}
.                                {}
%%

int main(void){
	int tok = 1;

	prepend_currdir();
    while (tok = yyparse())

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
