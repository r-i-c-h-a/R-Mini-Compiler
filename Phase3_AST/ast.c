#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "header.h"

node* createNode(char *data_type, val value, node* *list, int length)
{
    node *tmp = (node *) malloc(sizeof(node));
    strcpy(tmp->data_type, data_type);
    tmp->value = value;

    for (int i = 0; i < length; i++)
    {
        tmp->plist[i] = list[i];
    }
    

    tmp->nodes_n = length;

    return tmp;
}

void details(node *n)
{
   
    //printf("TYPE: %s\t", n->data_type);
    if(strcmp(n->data_type, "number_constant") == 0)
    {
        printf("TYPE: %-15s DATA: %-15d\n",n->data_type,n->value.const_num);
    }
    else if(strcmp(n->data_type, "string_constant") == 0)
    {
        printf("TYPE: %-15s DATA: %-15s\n",n->data_type,n->value.const_str);
    }
    else if(strcmp(n->data_type, "symbol") == 0)
    {


	//printf("%s\n",((n->value.p)->symbol_name));
        printf("TYPE: %-15s DATA: %-15s ADDRESS:%-15p\n",n->data_type,((n->value.p)->symbol_name),n->value.p);

    }
   else 
   {
        printf("TYPE: %-15s DATA:  \n",n->data_type);

    }
}

void printAST(node *m)
{
    if(m != NULL)
    {
        details(m);
        for (int i = 0; i < m->nodes_n; i++)
        {
            printAST(m->plist[i]);
        }
        
    }
}
