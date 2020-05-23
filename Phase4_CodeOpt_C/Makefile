all: run run1

run1: top
	./top

top: opt.h code_opt.c
	gcc opt.h code_opt.c -o top

run: a.out
	./a.out < testing.r 

a.out : lex.yy.c y.tab.c header.h 
	gcc -w lex.yy.c y.tab.c 
	
lex.yy.c : gram.l icg.y header.h
	yacc -d -v icg.y
	lex gram.l
	
clean :
	rm -f a.out lex.yy.c y.tab.c y.tab.h y.output output.txt const_* ICG.txt final.txt dead_code_removed.txt top
