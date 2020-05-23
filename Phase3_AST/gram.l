%{      
	#include "header.h"
	#include "y.tab.h"
	#include <string.h>
	#include "ast.h"
	
	int sym_last = -1;
   	sym_tab tab[SYM_TAB_SIZE];

%}

%option yylineno

%%

[ \t]   ;

#.*	;

"for"	{return T_FOR;}

"in"	{return T_IN;}

"while"	{return T_WHILE;}

"if"	{return T_IF;}

"else"	{return T_ELSE;}

\n+	{return T_NEWLINE;}

"+"	{return T_PLUS;}

"-"	{return T_MINUS;}

"*"	{return T_STAR;}

"/"	{return T_FSLASH;}

"("	{return T_LEFTPAREN;}

")"	{return T_RIGHTPAREN;}

"{"	{return T_LEFTCURL;}

"}"	{return T_RIGHTCURL;}

";"	{return T_SEMICOLON;}

":"	{return T_COLON;}

"<"	{return T_LT;}
        
"<="	{return T_LE;}
        
"=="	{return T_EQ;}
        
"!="	{return T_NE;}

">"	{return T_GT;}
        
">="	{return T_GE;}
        
"&&"	{return T_ANDD;}
        
"||"	{return T_ORD;}

"="	{return T_EQASSIGN;}
        
"<-"	{return T_LEFTASSIGN;}
        

"print(" {return T_PRINT;}

\".*\"			{ strcpy(yylval.type, "str");
			  strcpy(yylval.value, yytext);
  			  return CONST_STRING;}
        
[0-9]+(\.[0-9]+)?	{ strcpy(yylval.type, "num");
			  strcpy(yylval.value, yytext);
			  return CONST_NUMBER;}

[a-zA-Z_][a-zA-Z0-9_.]*	{ installID(yytext, yylineno);
			  strcpy(yylval.value, yytext);
  			  return SYM;}

.	                { return yytext[0];}

%%

int yywrap() { return 1; }

sym_tab *fetch_sym(char *symbol)
{
	for(int i=0;i<SYM_TAB_SIZE;i++){
        if(strcmp(symbol,tab[i].symbol_name) == 0){
            return &tab[i];
        }
    }

	return NULL;
}

void installID(char *symbol_name, int ln_no)
{
	if(lookup_symtab(symbol_name)== 0)
	{
		sym_last++;
		strcpy(tab[sym_last].symbol_name, symbol_name);
		tab[sym_last].ln_no = ln_no;
	}
}

void modify_symtab(char *symbol_name, char *data_type, char *val){
	for(int i=0; i<sym_last+1; i++){
		if(strcmp(symbol_name,tab[i].symbol_name)==0){
			strcpy(tab[i].data_type, data_type);
			strcpy(tab[i].val, val);
		}
	}
}

int lookup_symtab(char *symbol)
{
    int exists=0;
    for(int i=0;i<SYM_TAB_SIZE;i++){
        if(strcmp(symbol,tab[i].symbol_name) == 0){
            exists=1;
            break;
        }
    }
    return exists;
}


void print_symtab(sym_tab *tab, int c)                                            
{                                                                                   
    
    int i; 
    printf("----------------------------------SYMBOL TABLE--------------------------------------------------\n");
    printf("===============================================================================================|\n");                                                                       
    printf("%-25s %-15s %-25s %-15s\n",
           "Symbol", "Value", "Data Type", "Line number");  
    printf("===============================================================================================|\n");                                  
    for (i = 0; i < c; i++) {
        char *symbol = tab[i].symbol_name;                                                   
        printf("%-25s %-15s %-25s %-15d\n ",                                         
        symbol, tab[i].val, tab[i].data_type, tab[i].ln_no);  
	printf("----------------------------------------------------------------------------------------------|\n") ;                                           
    }                                                                               

}



