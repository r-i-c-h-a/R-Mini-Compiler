%define parse.error verbose

%{
    #include <stdio.h>
    #include "header.h"
	
	int is_val = 1;
	extern int sym_last;
	extern sym_tab tab[SYM_TAB_SIZE];
	
%}

%token T_NE T_GE T_GT T_LT T_LE T_EQ T_ANDD T_ORD
%token T_LEFTASSIGN T_EQASSIGN
%token T_IF T_ELSE T_FOR T_WHILE
%token T_IN
%token CONST_NUMBER CONST_STRING SYM
%token T_NEWLINE
%token T_SEMICOLON T_COLON
%token T_PRINT
%token T_PLUS T_MINUS T_STAR T_FSLASH
%token T_LEFTPAREN T_RIGHTPAREN
%token T_LEFTCURL T_RIGHTCURL

%nonassoc	T_NE T_LT T_LE T_GT T_GE T_EQ 
%left		T_ORD
%left		T_ANDD
%right		T_LEFTASSIGN
%right		T_EQASSIGN
%right		T_IF
%left		T_ELSE
%left		T_WHILE T_FOR
%left		T_PLUS T_MINUS
%left		T_STAR T_FSLASH
%nonassoc	T_LEFTPAREN
%left		T_COLON

%%

start: ls_exp;

ls_exp:
	| assn_or_exp
	| ls_exp T_SEMICOLON			
	| ls_exp T_SEMICOLON assn_or_exp
	| ls_exp T_NEWLINE	
	| ls_exp T_NEWLINE assn_or_exp		
    	| ls_exp T_NEWLINE print_stmt
    	| ls_exp T_SEMICOLON print_stmt
	| print_stmt;

assn_or_exp:   exp { $$ = $1; }
	| stmt
	| eq_assn;
        

stmt:
    	  T_IF ifcond assn_or_exp
	| T_IF ifcond assn_or_exp T_ELSE assn_or_exp
	| T_WHILE cond assn_or_exp
	| T_FOR forcond assn_or_exp;
	

eq_assn:    SYM T_EQASSIGN assn_or_exp	{ modify_symtab($1.value, $3.type, $3.value); };


cond:	  T_LEFTPAREN exp T_RIGHTPAREN
	| T_LEFTPAREN exp T_RIGHTPAREN T_NEWLINE;


forcond:  T_LEFTPAREN SYM T_IN exp T_RIGHTPAREN
	| T_LEFTPAREN SYM T_IN exp T_RIGHTPAREN T_NEWLINE;


ifcond:	  T_LEFTPAREN exp T_RIGHTPAREN
	| T_LEFTPAREN exp T_RIGHTPAREN T_NEWLINE;


print_stmt: T_PRINT exp T_RIGHTPAREN;


exp:      SYM
	| CONST_STRING	{ $$ = $1; }
	| CONST_NUMBER	{ $$ = $1;}
	| T_LEFTPAREN assn_or_exp T_RIGHTPAREN
  	| T_LEFTCURL ls_exp T_RIGHTCURL

	| exp T_LT exp
	| exp T_GT exp			
	| exp T_LE exp
	| exp T_GE exp				
	| exp T_NE exp						
	| exp T_EQ exp					
	| exp T_ANDD exp			
	| exp T_ORD exp
	
	| exp T_PLUS exp
	| exp T_MINUS exp
	| exp T_COLON exp
	| exp T_FSLASH exp
	| exp T_STAR exp
	
	

	| SYM T_LEFTASSIGN exp		{ modify_symtab($1.value, $3.type, $3.value); };

%%
#include <ctype.h>
int yyerror(const char *s)
{
    is_val = 0;
    printf("THIS PROGRAM IS NOT VALID\n");
    extern int yylineno;
    printf("The ERROR is: %s\n at LINE NUMBER: %d \n",s,yylineno);
    while(1)
	{
		int token = yylex();
		printf("Error: %d\n", token);
		if(token == T_SEMICOLON || token == T_NEWLINE )
			break;
	}
	yyparse();
    return 1;
}

int main()
{
    yyparse();

	if(is_val)
	{
		printf("--------------------------------");
		printf("This program is valid");
		printf("---------------------------------\n\n");
	}

	print_symtab(tab, sym_last+1);

}
