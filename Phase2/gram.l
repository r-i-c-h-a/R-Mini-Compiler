%option yylineno

%{
	#include <string.h>
	#include "header.h"
    #include "y.tab.h"


	Symbol table[TABLE_SIZE];
	int lastSym = -1;
%}

%%

#.*	;

[ \t]	;

\n+	{
		// printf("NEWLINE\n");
		return NEWLINE;
	}

"if"	{
			return IF;
		}

"else"	{
			return ELSE;
		}

"for"	{
			return FOR;
		}

"while"	{
			return WHILE;
		}

"in"	{
			return IN;
		}

"+"		{
			return PLUS;
		}

"-"		{
			return MINUS;
		}

"*"		{
			return STAR;
		}

"/"		{
			return FSLASH;
		}

";"		{
			return SEMICOLON;
		}

":"		{
			return COLON;
		}

"("		{
			return LEFT_PAREN;
		}

")"		{
			return RIGHT_PAREN;
		}

"{"		{
			return LEFT_CURLY;
		}

"}"		{
			return RIGHT_CURLY;
		}

"<"		{
  			return LT;
		}
        
"<="	{
  			return LE;
		}
        
"=="	{
			// printf("EQ\n");
  			return EQ;
		}
        
"!="	{
  			return NE;
		}

">"		{
  			return GT;
		}
        
">="	{
  			return GE;
		}
        
"&&"	{
  			return AND2;
		}
        
"||"	{
  			return OR2;
		}
        
"<-"	{
			// printf("<-\n");
  			return LEFT_ASSIGN;
		}
        
"="		{
			// printf("=\n");
  			return EQ_ASSIGN;
		}

"print("	{
				// printf("print(\n");
				return PRINT_;
			}
        
[0-9]+(\.[0-9]+)?	{
						// printf("NUM_CONST: %s, %d\n", yytext, yylineno);
						strcpy(yylval.type, "number");
						strcpy(yylval.value, yytext);
						return NUM_CONST;
					}

\".*\"	{
			// printf("STR_CONST: %s\n", yytext);
			strcpy(yylval.type, "string");
			strcpy(yylval.value, yytext);
  			return STR_CONST;
		}



[a-zA-Z_][a-zA-Z0-9_.]*	{
							installID(yytext, yylineno);
							// printf("SYMBOL: %s\n", yytext);
							strcpy(yylval.value, yytext);
  							return SYMBOL;
						}

.	{	return yytext[0];	}

%%

int yywrap() { return 1; }

int exists(char *sym)
{
    int flag=0;
    for(int i=0;i<TABLE_SIZE;i++){
        if(strcmp(sym,table[i].sym) == 0){
            flag=1;
            break;
        }
    }
    return(flag);
}

void installID(char *sym_name, int lineno)
{
	if(!exists(sym_name))
	{
		lastSym++;
		strcpy(table[lastSym].sym, sym_name);
		table[lastSym].lineno = lineno;
	}
}

void modifyID(char *symbol, char *dtype, char *value){
	for(int i=0; i<lastSym+1; i++){
		if(strcmp(symbol,table[i].sym)==0){
			strcpy(table[i].dtype, dtype);
			strcpy(table[i].value, value);
		}
	}
}

void display_table(Symbol *table, int n)                                            
{                                                                                   
    
    int i;                                                                          
    
    printf("%-20s %-10s %-20s %-10s\n",
           "SYMBOL", "TYPE", "VALUE", "LINE NO.");                                
    for (i = 0; i < n; i++) {
        char *sym = table[i].sym;                                                   
        /*
        char *type;
        switch (table[i].type) {                                                    
            case NUMBER:
                type = "NUMBER";                                                    
                break;
            case STRING:
                type = "STRING";                                                    
                break;                                                              
        }
        printf("%-20s %-10s %-20s %-10s\n",                                         
        sym, type, ad);                                                             
        */
        printf("%-20s %-10s %-20s %010d\n",                                         
        sym, table[i].dtype, table[i].value, table[i].lineno);                                              
    }                                                                               

}

/*
int main()
{

	int c;
	extern FILE *yyin;

	yyin = fopen("test.r", "r"); 
	// yylex();

	
	while(!feof(yyin))
	{
		yylex();
	} 

	display_table(table, lastSym+1);
} */
