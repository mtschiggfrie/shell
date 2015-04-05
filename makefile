all:
	flex Hello.l
	bison -dy Hello.y
	gcc lex.yy.c y.tab.c -o hello.exe