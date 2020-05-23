#define SYM_TAB_SIZE 400
#pragma once


typedef struct symbol_table
{
    int  ln_no;
    char symbol_name[50];
    char data_type[200];
    char val[200];
   
} sym_tab;

typedef struct 
{
    char type[40];
    char value[40];
} _yylval;

#define YYSTYPE _yylval


extern sym_tab tab[SYM_TAB_SIZE];
extern int sym_last;

int lookup_symtab(char *symbol);
void installID(char *symbol_name, int ln_no);
void modify_symtab(char *symbol_name, char *data_type, char *val);
void print_symtab(sym_tab *tab, int c);
