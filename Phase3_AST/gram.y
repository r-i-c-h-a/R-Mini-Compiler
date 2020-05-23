%define parse.error verbose

%{
    #include <stdio.h>
    #include "header.h"
    #include <stdlib.h>
    #include "ast.h"
	
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

start: ls_exp { $$ = $1;
		printAST($$.n_ptr); };

ls_exp:
	| assn_or_exp			 {  $$ = $1;  }
	| ls_exp T_SEMICOLON		 {  $$ = $1;  }	
	| ls_exp T_SEMICOLON assn_or_exp {  $$.n_ptr = createNode("SEQ", (val) 0, (node_plist) {$1.n_ptr, $3.n_ptr}, 2); }
	| ls_exp T_NEWLINE		 {  $$ = $1;  }
	| ls_exp T_NEWLINE assn_or_exp	 {  $$.n_ptr = createNode("SEQ", (val) 0, (node_plist) {$1.n_ptr, $3.n_ptr}, 2); };	
    	

assn_or_exp:   exp   { $$ = $1; }
	| stmt 	     { $$ = $1; }
	| eq_assn    { $$ = $1; }
	| print_stmt { };
        

stmt:
    	  T_IF ifcond assn_or_exp	{   $$.n_ptr = createNode("if", (val) 0, (node_plist) {$2.n_ptr, $3.n_ptr, NULL}, 3); }
	| T_IF ifcond assn_or_exp T_ELSE assn_or_exp  { $$.n_ptr = createNode("IF", (val) 0, (node_plist) {$2.n_ptr, $3.n_ptr, $5.n_ptr}, 3); }
	| T_WHILE cond assn_or_exp	{   $$.n_ptr = createNode("while", (val) 0, (node_plist) {$2.n_ptr, $3.n_ptr}, 2);   }
	| T_FOR forcond assn_or_exp	{   $$.n_ptr = createNode("for", (val) 0, (node_plist) {$2.n_ptr, $3.n_ptr}, 2);     };
														
	

eq_assn:    SYM T_EQASSIGN assn_or_exp	{   modify_symtab($1.value, $3.type, $3.value);
					    $1.n_ptr = createNode("symbol", (val) fetch_sym($1.value), (node_plist) {NULL}, 0);
					    $$.n_ptr = createNode("=", (val) 0, (node_plist) {$1.n_ptr, $3.n_ptr}, 2); };


cond:	  T_LEFTPAREN exp T_RIGHTPAREN	{   $$ = $2;   }
	| T_LEFTPAREN exp T_RIGHTPAREN T_NEWLINE  {  $$ = $2;  };


forcond:  T_LEFTPAREN SYM T_IN exp T_RIGHTPAREN  {  $2.n_ptr = createNode("symbol", (val) fetch_sym($2.value), (node_plist) {NULL}, 0);	
						    $$.n_ptr = createNode("for_condition", (val) 0, (node_plist) {$2.n_ptr, $4.n_ptr}, 2);  }
	| T_LEFTPAREN SYM T_IN exp T_RIGHTPAREN T_NEWLINE  {  $2.n_ptr = createNode("symbol", (val) fetch_sym($2.value), (node_plist) {NULL}, 0);	
							      $$.n_ptr = createNode("for_condition", (val) 0, (node_plist) {$2.n_ptr, $4.n_ptr}, 2);  };


ifcond:	  T_LEFTPAREN exp T_RIGHTPAREN	{  $$ = $2;  }
	| T_LEFTPAREN exp T_RIGHTPAREN T_NEWLINE  {  $$ = $2;  };


print_stmt: T_PRINT exp T_RIGHTPAREN	{  $$.n_ptr = createNode("print", (val) 0, (node_plist) {$2.n_ptr}, 1);  };


exp:      SYM 				{  $1.n_ptr = createNode("symbol", (val) fetch_sym($1.value), (node_plist) {NULL}, 0);
					   $$ = $1;  }
	| CONST_STRING			{ val tmp;
    			  		  strcpy(tmp.const_str, $1.value);
					  $1.n_ptr = createNode("string_constant", tmp, (node_plist) {NULL}, 0);
					  $$ = $1; }
	| CONST_NUMBER			{ $1.n_ptr = createNode("number_constant", (val) atoi($1.value), (node_plist) {NULL}, 0);
                                          $$ = $1 ; };
	| T_LEFTPAREN assn_or_exp T_RIGHTPAREN  {  $$ = $2;  }
  	| T_LEFTCURL ls_exp T_RIGHTCURL {  $$ = $2;  }

	| exp T_LT exp			{  $$.n_ptr = createNode("<", (val) 0, (node_plist) {$1.n_ptr, $3.n_ptr}, 2); }
	| exp T_GT exp			{  $$.n_ptr = createNode(">", (val) 0, (node_plist) {$1.n_ptr, $3.n_ptr}, 2); }
	| exp T_LE exp			{  $$.n_ptr = createNode("<=",(val) 0, (node_plist) {$1.n_ptr, $3.n_ptr}, 2); }
	| exp T_GE exp			{  $$.n_ptr = createNode(">=",(val) 0, (node_plist) {$1.n_ptr, $3.n_ptr}, 2); }	
	| exp T_NE exp			{  $$.n_ptr = createNode("!=",(val) 0, (node_plist) {$1.n_ptr, $3.n_ptr},2);  } 			
	| exp T_EQ exp			{  $$.n_ptr = createNode("==",(val) 0, (node_plist) {$1.n_ptr, $3.n_ptr}, 2); }		
	| exp T_ANDD exp		{  $$.n_ptr = createNode("&&",(val) 0, (node_plist) {$1.n_ptr, $3.n_ptr}, 2); }	
	| exp T_ORD exp			{  $$.n_ptr = createNode("||",(val) 0, (node_plist) {$1.n_ptr, $3.n_ptr}, 2); }
	
	| exp T_PLUS exp		{  $$.n_ptr = createNode("+", (val) 0, (node_plist) {$1.n_ptr, $3.n_ptr}, 2); }
	| exp T_MINUS exp		{  $$.n_ptr = createNode("-", (val) 0, (node_plist) {$1.n_ptr, $3.n_ptr}, 2); }
	| exp T_COLON exp		{  $$.n_ptr = createNode(":", (val) 0, (node_plist) {$1.n_ptr, $3.n_ptr}, 2); }
	| exp T_FSLASH exp		{  $$.n_ptr = createNode("*", (val) 0, (node_plist) {$1.n_ptr, $3.n_ptr}, 2); }
	| exp T_STAR exp		{  $$.n_ptr = createNode("/", (val) 0, (node_plist) {$1.n_ptr, $3.n_ptr}, 2); };
	
	

	| SYM T_LEFTASSIGN exp		{  modify_symtab($1.value, $3.type, $3.value);
					   $1.n_ptr = createNode("symbol", (val) fetch_sym($1.value), (node_plist) {NULL}, 0);
					   $$.n_ptr = createNode("<-", (val) 0, (node_plist) {$1.n_ptr, $3.n_ptr}, 2); };

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
		printf("---------------------------------");
		printf("This program is valid");
		printf("----------------------------------\n\n");
	}

	print_symtab(tab, sym_last+1);

}
