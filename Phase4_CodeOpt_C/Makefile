all: run
 
run1: code
	./code

code: opt.h code_opt.c
	gcc opt.h code_opt.c

run: a.out 
	./a.out < testing.r

a.out : lex.yy.c y.tab.c header.h ast.h ast.c
	gcc lex.yy.c y.tab.c ast.c
	
lex.yy.c : gram.l icg.y header.h
	yacc -d -v icg.y
	lex gram.l
	
clean :
	rm -f a.out lex.yy.c y.tab.c y.tab.h y.output output.txt const_* ICG.txt
