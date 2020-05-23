#include "header.h"

typedef union val
{
    sym_tab *p;
    char const_str[30];
    int const_num;
    
} val;

typedef struct node
{
    union val value;
    char data_type[30];
    int nodes_n;
    struct node* plist[15];
} node;
#define node_plist node * []

node* createNode(char *data_type, val value, node* *plist, int length);
void printAST(node *m);


    
