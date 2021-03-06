%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> 
#include <string.h>
#include <fcntl.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "xsh_funcs.H"
#include "sh_funcs.H"
#include "cmd_funcs.H"

#include "sh_errs.H"

#define YYSTYPE char *

/*********************************************/
/* Bug List */
/*********************************************/
/* 

4. account for nested aliasing 

6. echo name > file prepends name

8. prevent aliasing/envvaring a cmd name

*/

/*********************************************/
/* Headers */
/*********************************************/
/* 
cmd_funcs.H
	run_in_background, set_file_in, set_file_out, run_in_background, do_append
	init_a_cmd, add_args, init_or_addarg
	sh_cmdmap, xsh_cmdmap
	redirect_input, redirect_output
	execute_cmds, clear_cmds

xsh_funcs.H
	xsh_currdir, xsh_ls, xsh_echo

sh_funcs.H
	prepend_currdir
	sh_setenv, sh_printenv, sh_unsetenv
	sh_alias, sh_unalias, sh_aliaslist
	sh_cd, sh_bye

sh_errs.H
	errs_map
*/	

%}

%token OTHER_TOK INTO_TOK FROM_TOK STDOUT_TOK STDERR_TOK BACKGROUND_TOK PIPE_TOK EOF_TOK ENVVAR_TOK QUOTE_TOK

%%


command:
		//init_a_cmd with cmd_name = OTHER_TOK
		OTHER_TOK					{ $$ = $1; init_or_addarg($1);}
		//change ${env_var_name} with its corresponding word and add to init or addarg
		| ENVVAR_TOK				{ $$ = $1; init_or_addarg(sub_env_var($1));}
		//take off the quotes and push to init or addarg
		| QUOTE_TOK					{ $$ = $1; init_or_addarg($1);}		
		//push arg onto argv
		| command OTHER_TOK			{ $$ = $1; init_or_addarg($2);}
		//subsitute env var for word
		| command ENVVAR_TOK		{ $$ = $1; init_or_addarg(sub_env_var($2));}
		//take off the quotes and push to init or addarg
		| command QUOTE_TOK			{ $$ = $1; init_or_addarg($2);}	
		//pipe commands, increment cmd argstack to push args to correct argv later
		| command PIPE_TOK OTHER_TOK{ $$ = $3; read_cmd_next(); init_or_addarg($3);}
		//redirecting already done, just reducing statement
		| command redirect 			{ $$ = $1;}
		//execute command in background
		| command BACKGROUND_TOK 	{ $$ = $1; run_in_background();}
		//execute the commands that have been defined at end of line, then clears cmdtab
		| command EOF_TOK			{ $$ = $1; execute_cmds(); clear_cmds(); prepend_currdir();}
		;

redirect:
		input_redirect { ;}
		| output_redirect { ;}
		| redirect redirect { ;} //fix allow chaining of redirects later

input_redirect:
		//redirect file_in
		FROM_TOK OTHER_TOK			{ set_file_in($2);}
		;

output_redirect:
		//redirect file_out
		INTO_TOK OTHER_TOK			{ set_file_out($2);}//output_redirect = file_name
		//redirect
		| INTO_TOK INTO_TOK	OTHER_TOK		{ do_append(); set_file_out($3);}//append, push back INTO_TOK
		| STDERR_TOK INTO_TOK STDOUT_TOK	{ stderr_to_stdout();}//stderr outputs to stdout
		| STDERR_TOK INTO_TOK OTHER_TOK		{ set_file_err($3);}//stderr outputs to file_out
		;

%%