all: run

run: a.out code_optimisation.py
	./a.out < testing.r
	python3 code_optimisation.py

a.out : lex.yy.c y.tab.c header.h 
	gcc lex.yy.c y.tab.c 
	
lex.yy.c : gram.l icg.y header.h
	yacc -d -v icg.y
	lex gram.l
	
clean :
	rm -f a.out lex.yy.c y.tab.c y.tab.h y.output output.txt
