%define parse.error verbose

%{
    #include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "header.h"
	#include "ast.h"

	int valid = 1;

	extern char * yytext;
%}


%token NUM_CONST STR_CONST SYMBOL
%token LT LE EQ NE GE GT AND2 OR2
%token LEFT_ASSIGN EQ_ASSIGN
%token IF ELSE FOR WHILE
%token IN

%token PRINT_
%token NEWLINE

%token PLUS MINUS STAR FSLASH
%token SEMICOLON COLON
%token LEFT_PAREN RIGHT_PAREN
%token LEFT_CURLY RIGHT_CURLY


%left		WHILE FOR
%right		IF
%left		ELSE
%right		LEFT_ASSIGN
%right		EQ_ASSIGN
%left		OR2
%left		AND2
%nonassoc	GT GE LT LE EQ NE
%left		PLUS MINUS
%left		STAR FSLASH
%left		COLON
%nonassoc	LEFT_PAREN

%%

start: exprlist		{
						$$ = $1;
						//printf("%p\n", $1.nodeptr);
						display_subtree($$.nodeptr);
					}
    ;

exprlist:
	|	expr_or_assign							{	$$ = $1;	}
	|	exprlist SEMICOLON expr_or_assign		{
								$$.nodeptr = make_node("SEQ", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
												}
	|	exprlist SEMICOLON						{	$$ = $1;	}
	|	exprlist NEWLINE expr_or_assign			{	
								$$.nodeptr = make_node("SEQ", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
												}
	|	exprlist NEWLINE						{	$$ = $1;	}
;

expr_or_assign:   expr	{	$$ = $1;	}
	|   equal_assign	{	$$ = $1;	}
    |   statement		{	$$ = $1;	}
	| print_statement 	{ }
    ;

statement:
    	IF ifcond expr_or_assign						{
								$$.nodeptr = make_node("IF", (data) 0, (NodePtrList) {$2.nodeptr, $3.nodeptr, NULL}, 3);
														}
	|	IF ifcond expr_or_assign ELSE expr_or_assign	{
								$$.nodeptr = make_node("IF", (data) 0, (NodePtrList) {$2.nodeptr, $3.nodeptr, $5.nodeptr}, 3);
														}
	|	FOR forcond expr_or_assign						{
								$$.nodeptr = make_node("FOR", (data) 0, (NodePtrList) {$2.nodeptr, $3.nodeptr}, 2);
														}
	|	WHILE cond expr_or_assign						{
								$$.nodeptr = make_node("WHILE", (data) 0, (NodePtrList) {$2.nodeptr, $3.nodeptr}, 2);
														}

    ;

equal_assign:
	SYMBOL EQ_ASSIGN expr_or_assign	{ 
								printf("eq_assign: %s %s, SYMBOL: %s\n", $3.type, $3.value, $1.value); 
								modifyID($1.value, $3.type, $3.value); 

								$1.nodeptr = make_node("SYMBOL", (data) getSymbol($1.value), (NodePtrList) {NULL}, 0);
								$$.nodeptr = make_node("=", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
									}
    ;

print_statement: 
	PRINT_ expr RIGHT_PAREN			{
										$$.nodeptr = make_node("PRINT", (data) 0, (NodePtrList) {$2.nodeptr}, 1);
									}
    ;


cond:	LEFT_PAREN expr RIGHT_PAREN				{	$$ = $2;	}
	|	LEFT_PAREN expr RIGHT_PAREN NEWLINE		{	$$ = $2;	}
    ;


ifcond:	LEFT_PAREN expr RIGHT_PAREN				{	$$ = $2;	}
	|	LEFT_PAREN expr RIGHT_PAREN NEWLINE		{	$$ = $2;	}
    ;


forcond:	LEFT_PAREN SYMBOL IN expr RIGHT_PAREN		{	
							$2.nodeptr = make_node("SYMBOL", (data) getSymbol($2.value), (NodePtrList) {NULL}, 0);	
							$$.nodeptr = make_node("FORCOND", (data) 0, (NodePtrList) {$2.nodeptr, $4.nodeptr}, 2);
														}
	|	LEFT_PAREN SYMBOL IN expr RIGHT_PAREN NEWLINE	{
							$2.nodeptr = make_node("SYMBOL", (data) getSymbol($2.value), (NodePtrList) {NULL}, 0);	
							$$.nodeptr = make_node("FORCOND", (data) 0, (NodePtrList) {$2.nodeptr, $4.nodeptr}, 2);
														}
    ;



expr:   SYMBOL		{
						$1.nodeptr = make_node("SYMBOL", (data) getSymbol($1.value), (NodePtrList) {NULL}, 0);
						$$ = $1;
					}
    |   NUM_CONST	{ 
						printf("num_const: %s %s\n", $1.type, $1.value);
						$1.nodeptr = make_node("NUM_CONST", (data) atoi($1.value), (NodePtrList) {NULL}, 0); // check what to do for double type
						$$ = $1;
					}
    |   STR_CONST	{ 
						printf("str_const: %s %s\n", $1.type, $1.value);
						data temp_;
    						strcpy(temp_.str_const, $1.value);
						$1.nodeptr = make_node("STR_CONST", temp_, (NodePtrList) {NULL}, 0);
						$$ = $1; 
					}

    |	LEFT_CURLY exprlist RIGHT_CURLY				{	$$ = $2;	}
	|	LEFT_PAREN expr_or_assign RIGHT_PAREN		{	$$ = $2;	}

    |	expr COLON expr		{
								$$.nodeptr = make_node(":", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
							}
	|	expr PLUS expr		{
								$$.nodeptr = make_node("+", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
							}
	|	expr MINUS expr		{
								$$.nodeptr = make_node("-", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
							}
	|	expr STAR expr		{
								$$.nodeptr = make_node("*", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
							}
	|	expr FSLASH expr	{
								$$.nodeptr = make_node("/", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
							}

    |	expr LT expr		{
								$$.nodeptr = make_node("<", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
							}
	|	expr LE expr		{
								$$.nodeptr = make_node("<=", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
							}
	|	expr EQ expr		{
								$$.nodeptr = make_node("==", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
							}
	|	expr NE expr		{
								$$.nodeptr = make_node("!=", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
							}
	|	expr GE expr		{
								$$.nodeptr = make_node(">=", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
							}
	|	expr GT expr		{
								$$.nodeptr = make_node(">", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
							}
	|	expr AND2 expr		{
								$$.nodeptr = make_node("&&", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
							}
	|	expr OR2 expr		{
								$$.nodeptr = make_node("||", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
							}

	|	SYMBOL LEFT_ASSIGN expr		{ 
								printf("left_assign: %s %s, SYMBOL: %s\n", $3.type, $3.value, $1.value); 
								modifyID($1.value, $3.type, $3.value); 
								$1.nodeptr = make_node("SYMBOL", (data) getSymbol($1.value), (NodePtrList) {NULL}, 0);
								$$.nodeptr = make_node("<-", (data) 0, (NodePtrList) {$1.nodeptr, $3.nodeptr}, 2);
									}
    
    ;

%%

#include <ctype.h>
int yyerror(const char *s)
{
    printf("Invalid program\n");
    valid = 0;
	extern int yylineno;
	printf("Line no: %d \n The error is: %s\n",yylineno,s);

	while(1)
	{
		int tok = yylex();
		// printf("Err: %d \n", tok);
		extern char * yytext;
		printf("Err: %s \n", yytext);
		if(tok == NEWLINE || tok == SEMICOLON)
			break;
	}
	yyparse();
    return 1;
}

int main()
{
    yyparse();

	if(valid)
	{
		printf("Valid program\n");
	}

	//display_table(table, lastSym+1);

}
