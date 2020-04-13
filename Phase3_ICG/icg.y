%define parse.error verbose

%{
    #include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "header.h"
	#include "ast.h"

	int valid = 1;
	int label_count=0;
        int temp_count=0;
        char buffer[300];
        int cond = 0;
	int step = 0;
        //char reg[7][10]={"t1","t2","t3","t4","t5","t6"};
        extern FILE *yyout;  		/* Pointer to the output file */
	extern char *yylex();

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

start: exprlist		{	$$ = $1;	}
    ;

exprlist:
	|	expr_or_assign					{	$$ = $1;	}
	|	exprlist SEMICOLON expr_or_assign	{}
	|	exprlist SEMICOLON				{	$$ = $1;	}
	|	exprlist NEWLINE expr_or_assign		{}
	|	exprlist NEWLINE				{	$$ = $1;	}
    ;

expr_or_assign:   expr	{}
	|   equal_assign	{	fprintf(yyout, "%s\n", $1.value);	}
    |   loop_statement		{	fprintf(yyout, "GOTO L%d\nL%d:\n",(step-2),(step-1)); step-=2;	}
	| if_statement	{	fprintf(yyout,"L%d:\n",(step-1));  step-=1;		}
   | print_statement	{	$$ = $1;	fprintf(yyout, "%s\n", $1.value);	}
    ;

if_statement:
    	IF ifcond  						{
								sprintf(buffer,"T%d = %s"
									       "IF FALSE T%d GOTO L%d"
						       				"\n" ,
										temp_count,$2.value,temp_count,label_count);
								strcpy($$.value,buffer); 
								++temp_count;
								fprintf(yyout, "%s\n", buffer);
								label_count+=1;
								step=label_count;				
										} expr_or_assign
	| ELSE 						{
								label_count+=2;
								step=label_count; 
										} expr_or_assign
;

loop_statement:		FOR forcond  					{} expr_or_assign
	|	WHILE cond  						{
								sprintf(buffer,"L%d: \nT%d = %s \n"
									       "IF FALSE T%d GOTO L%d",
						  			       label_count,temp_count,$2.value,temp_count,(label_count+1));
					 			strcpy($$.value,buffer);
								++temp_count;
								label_count+=2;
								step=label_count;
								fprintf(yyout, "%s\n", buffer);
														} expr_or_assign

    ;

equal_assign:
	SYMBOL EQ_ASSIGN expr	{ 
								modifyID($1.value, $3.type, $3.value); 
								sprintf(buffer,"T%d = %s"
									       "\n%s = T%d\n" ,
									       temp_count,$3.value,$1.value,temp_count);
								++temp_count;
								strcpy($$.value,buffer);
									}
    ;

print_statement: 
	PRINT_ expr RIGHT_PAREN			{
										sprintf(buffer,"T%d = %s"
									      		       "\nprint T%d\n" ,
									      	temp_count,$2.value,temp_count);
										++temp_count;
										strcpy($$.value,buffer);
									}
    ;


cond:	LEFT_PAREN expr RIGHT_PAREN				{	$$ = $2;	}
	|	LEFT_PAREN expr RIGHT_PAREN NEWLINE		{	$$ = $2;	}
    ;


ifcond:	LEFT_PAREN expr RIGHT_PAREN				{	$$ = $2;	}
	|	LEFT_PAREN expr RIGHT_PAREN NEWLINE		{	$$ = $2;	}
    ;


forcond:	LEFT_PAREN SYMBOL IN expr COLON expr RIGHT_PAREN		{
								sprintf(buffer,"L%d: \nT%d = T%d && T%d\n"
									       "T%d = T%d >= T%d\n"
									       "T%d = %s\n"
									       "T%d = %s\n\n"
									       "T%d = T%d <= T%d\n"
									       "T%d = %s\n"
									       "T%d = %s\n"
									       "IF FALSE T%d GOTO L%d",
						  			       label_count,temp_count,(temp_count+1),(temp_count+2),(temp_count+1),
									       (temp_count+3),(temp_count+4),(temp_count+3),$2.value,(temp_count+4),$4.value,
									       (temp_count+2),(temp_count+5),(temp_count+6),(temp_count+5),
									        $2.value,(temp_count+6)
									       ,$6.value,temp_count,(label_count+1));
					 			strcpy($$.value,buffer);
								temp_count+=7;
								label_count+=2;
								step=label_count;
								fprintf(yyout, "%s\n", buffer);
														}
	|	LEFT_PAREN SYMBOL IN expr COLON expr RIGHT_PAREN NEWLINE	{
								sprintf(buffer,"L%d: \nT%d = T%d && T%d\n"
									       "T%d = T%d >= T%d\n"
									       "T%d = %s\n"
									       "T%d = %s\n\n"
									       "T%d = T%d <= T%d\n"
									       "T%d = %s\n"
									       "T%d = %s\n"
									       "IF FALSE T%d GOTO L%d",
						  			       label_count,temp_count,(temp_count+1),(temp_count+2),(temp_count+1),
									       (temp_count+3),(temp_count+4),(temp_count+3),$2.value,(temp_count+4),$4.value,
									       (temp_count+2),(temp_count+5),(temp_count+6),(temp_count+5),
									        $2.value,(temp_count+6)
									       ,$6.value,temp_count,(label_count+1));
					 			strcpy($$.value,buffer);
								temp_count+=7;
								label_count+=2;
								step=label_count;
								fprintf(yyout, "%s\n", buffer);
														}
    ;

expr:   SYMBOL		{	$$ = $1; modifyID($1.value, "symbol", $1.value);	}
	|   NUM_CONST	{ 	$$ = $1;	}
	|   STR_CONST	{ 
						data temp_;
    						strcpy(temp_.str_const, $1.value);
						$$ = $1; 
					}
	|	LEFT_CURLY exprlist RIGHT_CURLY				{	$$ = $2;	}
	|	LEFT_PAREN expr_or_assign RIGHT_PAREN		{	$$ = $2;	}

    |	expr COLON expr		{				sprintf(buffer,"T%d : T%d\n"
										"T%d = %s"
									       "\nT%d = %s\n",
										temp_count,(temp_count+1),
									       temp_count,$1.value,(temp_count+1),$3.value);
								++temp_count;
								++temp_count;
								strcpy($$.value,buffer);}
	|	expr PLUS expr		{			sprintf(buffer,"T%d + T%d\n"
										"T%d = %s"
									       "\nT%d = %s\n",
										temp_count,(temp_count+1),
									       temp_count,$1.value,(temp_count+1),$3.value);
								++temp_count;
								++temp_count;
								strcpy($$.value,buffer);}
	|	expr MINUS expr		{			sprintf(buffer,"T%d - T%d\n"
										"T%d = %s"
									       "\nT%d = %s\n",
										temp_count,(temp_count+1),
									       temp_count,$1.value,(temp_count+1),$3.value);
								++temp_count;
								++temp_count;
								strcpy($$.value,buffer);}
	|	expr STAR expr		{			sprintf(buffer,"T%d * T%d\n"
										"T%d = %s"
									       "\nT%d = %s\n",
										temp_count,(temp_count+1),
									       temp_count,$1.value,(temp_count+1),$3.value);
								++temp_count;
								++temp_count;
								strcpy($$.value,buffer);}
	|	expr FSLASH expr	{			sprintf(buffer,"T%d / T%d\n"
										"T%d = %s"
									       "\nT%d = %s\n",
										temp_count,(temp_count+1),
									       temp_count,$1.value,(temp_count+1),$3.value);
								++temp_count;
								++temp_count;
								strcpy($$.value,buffer);}
	|	expr LT expr		{			sprintf(buffer,"T%d < T%d\n"
										"T%d = %s"
									       "\nT%d = %s\n",
										temp_count,(temp_count+1),
									       temp_count,$1.value,(temp_count+1),$3.value);
								++temp_count;
								++temp_count;
								strcpy($$.value,buffer);}
	|	expr LE expr		{			sprintf(buffer,"T%d <= T%d\n"
										"T%d = %s"
									       "\nT%d = %s\n",
										temp_count,(temp_count+1),
									       temp_count,$1.value,(temp_count+1),$3.value);
								++temp_count;
								++temp_count;
								strcpy($$.value,buffer);}
	|	expr EQ expr		{			sprintf(buffer,"T%d == T%d\n"
										"T%d = %s"
									       "\nT%d = %s\n",
										temp_count,(temp_count+1),
									       temp_count,$1.value,(temp_count+1),$3.value);
								++temp_count;
								++temp_count;
								strcpy($$.value,buffer);}
	|	expr NE expr		{			sprintf(buffer,"T%d != T%d\n"
										"T%d = %s"
									       "\nT%d = %s\n",
										temp_count,(temp_count+1),
									       temp_count,$1.value,(temp_count+1),$3.value);
								++temp_count;
								++temp_count;
								strcpy($$.value,buffer);}
	|	expr GE expr		{			sprintf(buffer,"T%d >= T%d\n"
										"T%d = %s"
									       "\nT%d = %s\n",
										temp_count,(temp_count+1),
									       temp_count,$1.value,(temp_count+1),$3.value);
								++temp_count;
								++temp_count;
								strcpy($$.value,buffer);}
	|	expr GT expr		{			sprintf(buffer,"T%d > T%d\n"
										"T%d = %s"
									       "\nT%d = %s\n",
										temp_count,(temp_count+1),
									       temp_count,$1.value,(temp_count+1),$3.value);
								++temp_count;
								++temp_count;
								strcpy($$.value,buffer);}
	|	expr AND2 expr		{			sprintf(buffer,"T%d && T%d\n"
										"T%d = %s"
									       "\nT%d = %s\n",
										temp_count,(temp_count+1),
									       temp_count,$1.value,(temp_count+1),$3.value);
								++temp_count;
								++temp_count;
								strcpy($$.value,buffer);}
	|	expr OR2 expr		{			sprintf(buffer,"T%d || T%d\n"
										"T%d = %s"
									       "\nT%d = %s\n",
										temp_count,(temp_count+1),
									       temp_count,$1.value,(temp_count+1),$3.value);
								++temp_count;
								++temp_count;
								strcpy($$.value,buffer);}

	|	SYMBOL LEFT_ASSIGN expr		{ 
								modifyID($1.value, $3.type, $3.value);
								sprintf(buffer,"T%d = %s"
									       "\n%s = T%d\n" ,
									       temp_count,$3.value,$1.value,temp_count);
								++temp_count;
								strcpy($$.value,buffer);
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
	yyout = fopen("output.txt","a");
    yyparse();

	if(valid)
	{
		printf("Valid program\n");
	}

}
