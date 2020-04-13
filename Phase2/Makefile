all: run

run: a.out
	./a.out < test.r

a.out : lex.yy.c y.tab.c
	gcc lex.yy.c y.tab.c -w
	
lex.yy.c : gram.l gram.y
	yacc -d -v gram.y
	lex gram.l

clean: 
	rm -f a.out lex.yy.c y.tab.c y.tab.h y.output
