all:
	flex lex.l
	bison -dy grammar.y
	gcc lex.yy.c y.tab.c -o shell.exe