#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

typedef struct list{
	char item[100];
} list_;

typedef struct dict{
	char key[100];
	char value[100];
} dict_;

//list_ list[200];
//dict_ dict[200];

char arith[] = {'+','-','*','/'};
char *logic[] = {"<",">","<=",">=","==","!="};
char *rel[] = {"&&","||"};
char *keywords[] = {"IF","FALSE","GOTO","print"};

char *strip(char *s){
        size_t size;
        char *end;

        size = strlen(s);

        if (!size)
                return s;

        end = s + size - 1;
        while (end >= s && isspace(*end))
                end--;
        *(end + 1) = '\0';

        while (*s && isspace(*s))
                s++;

        return s;
}

int istemp(char *s){
	if(s[0]=='T') return 1;
	else return 0;
}

int islevel(char *s){
	if(s[0]=='L') return 1;
	else return 0;
}

int isnum(char *s){
	int i=0;
	int len = strlen(s);
	int flag = 1;
	for(i=0;i<len;i++){
		if(isdigit(s[i])==0) return 0;
	}
	return 1;
}

int isarith(char *s){
	int i = 0;
	for(i=0;i<4;i++){
		if(s[0]==arith[i]) return 1;
	} 
	return 0;
}

/*int indict(dict_ *d,char *s){
	int i = 0;
	while(d[i].key){
		if(strcmp(s,d[i].key)==0) return 1;
		i+=1;
		printf("%s %s\n",d[i].key,d[i].value);
	}
	return 0;
}
*/

void finalICG(FILE *fp){
	FILE *fp1,*fp2;
	fp1 = fopen("ICG.txt","a");
	char chunk[128];
	dict_ i_t[200];
	//char *i_t[200];
	int d = 0;
	while(fgets(chunk, sizeof(chunk), fp) != NULL) {
	strcpy(chunk,strip(chunk));
	list_ toks[200];
	char *token = strtok(chunk, " ");
	int length = 0;
	while( token != NULL ) {
		strcpy(toks[length].item,token);
		token = strtok(NULL, " ");
		length+=1;
   	}
	//printf("%d\n",length);
	if(length == 3){
		//printf("%s %s %s\n",toks[0].item,toks[1].item,toks[2].item);
		if(istemp(toks[0].item) && toks[1].item[0] == '=' && !(istemp(toks[2].item))){
				strcpy(i_t[d].key,toks[0].item);
				strcpy(i_t[d].value,toks[2].item);
				d+=1;
		}
	}
	}
	fp2 = fopen("output.txt","r");
	while(fgets(chunk, sizeof(chunk), fp2) != NULL) {
	strcpy(chunk,strip(chunk));
	//printf("%s",chunk);
	list_ toks[200];
	char *token = strtok(chunk, " ");
	int length = 0;
	while( token != NULL ) {
		strcpy(toks[length].item,token);
		token = strtok(NULL, " ");
		length+=1;
	}
	int flag = 1;
	if(length >=1){
		for(int i=0; i<d; i++){
		if(strcmp(i_t[i].key,toks[0].item)==0){
			flag = 0;
		}}
		if(flag){
			printf("%s ",toks[0].item);
			fprintf(fp1,"%s ",toks[0].item);
			for(int i=1; i<length; i++){
				for(int j=0; j<d; j++){
					if(strcmp(i_t[j].key,toks[i].item)==0){
						strcpy(toks[i].item,i_t[j].value);
						//printf("HERE\n");
					}				
				}
			printf("%s ",toks[i].item);
			fprintf(fp1,"%s ",toks[i].item);
			}
		printf("\n");
		fprintf(fp1,"\n");
		}
	}
}
	fclose(fp);
	fclose(fp1);
	fclose(fp2);
}

void constant_propagation(FILE *fp,FILE *fp1){
	FILE *fp2;
	char chunk[128];
	dict_ i_t[200];
	//char *i_t[200];
	int d = 0;
	while(fgets(chunk, sizeof(chunk), fp) != NULL) {
	strcpy(chunk,strip(chunk));
	list_ toks[200];
	char *token = strtok(chunk, " ");
	int length = 0;
	while( token != NULL ) {
		strcpy(toks[length].item,token);
		token = strtok(NULL, " ");
		length+=1;
   	}
	//printf("%d\n",length);
	if(length == 3){
		if(toks[0].item && toks[1].item[0] == '=' && (isnum(toks[2].item))){
				strcpy(i_t[d].key,toks[0].item);
				strcpy(i_t[d].value,toks[2].item);
				//printf("%s %s %s\n",i_t[d].key,toks[1].item,i_t[d].value);
				d+=1;
		}
	}
	}
	fp2 = fopen("ICG.txt","r");
	while(fgets(chunk, sizeof(chunk), fp2) != NULL) {
	strcpy(chunk,strip(chunk));
	//printf("%s\n",chunk);
	list_ toks[200];
	char *token = strtok(chunk, " ");
	int length = 0;
	while( token != NULL ) {
		strcpy(toks[length].item,token);
		token = strtok(NULL, " ");
		length+=1;
	}
	int flag = 1;
	if(length == 5 && isarith(toks[3].item)){
		if(flag){
			//printf("%s ",toks[0].item);
			fprintf(fp1,"%s ",toks[0].item);
			for(int i=1; i<length; i++){
				for(int j=0; j<d; j++){
					if(strcmp(i_t[j].key,toks[i].item)==0){
						strcpy(toks[i].item,i_t[j].value);
						//printf("HERE\n");
					}				
				}
			//printf("%s ",toks[i].item);
			fprintf(fp1,"%s ",toks[i].item);
			}
		//printf("\n");
		fprintf(fp1,"\n");
		}
	}
	else if(length == 3){
		if(!(istemp(toks[0].item)) && toks[1].item[0] == '='){
			for(int i=0; i<d; i++){
				if(strcmp(i_t[i].key,toks[2].item)==0){
					strcpy(toks[2].item,i_t[i].value);
			}}
		
		//printf("%s %s %s\n",toks[0].item,toks[1].item,toks[2].item);
		fprintf(fp1,"%s %s %s\n",toks[0].item,toks[1].item,toks[2].item);
		}
	}
	else if(!(length==3 && istemp(toks[0].item))){
		for(int i=0; i<length; i++){
			//printf("%s ",toks[i].item);
			fprintf(fp1,"%s ",toks[i].item);
		}
		//printf("\n");
		fprintf(fp1,"\n");
	}
}
	fclose(fp);
	fclose(fp1);
	fclose(fp2);
}

int eval(int a, int b, char *c){
	switch(c[0]){
		case '+': return a + b;
		case '-': return a - b;
		case '*': return a * b;
		case '/': return a / b;	
	}
}

void constant_folding(FILE *fp,FILE *fp1){
	//FILE *fp2;
	char chunk[128];
	while(fgets(chunk, sizeof(chunk), fp) != NULL) {
	strcpy(chunk,strip(chunk));
	list_ toks[200];
	char *token = strtok(chunk, " ");
	int length = 0;
	while( token != NULL ) {
		strcpy(toks[length].item,token);
		token = strtok(NULL, " ");
		length+=1;
   	}
	//printf("%d\n",length);
	if(length == 5 && isarith(toks[3].item) && (isnum(toks[2].item)) && (isnum(toks[4].item))){
				//printf("%s %s %s\n",i_t[d].key,toks[1].item,i_t[d].value);
				char res[100];
				sprintf(toks[2].item,"%d",eval(atoi(toks[2].item),atoi(toks[4].item),toks[3].item));
				//printf("%s %s %s\n",toks[0].item,toks[1].item,toks[2].item);
				fprintf(fp1,"%s %s %s\n",toks[0].item,toks[1].item,toks[2].item);
		}
	else{
		for(int i=0; i<length; i++){
			//printf("%s ",toks[i].item);
			fprintf(fp1,"%s ",toks[i].item);
		}
		//printf("\n");
		fprintf(fp1,"\n");
	}	
	}
	fclose(fp);
	fclose(fp1);
	//fclose(fp2);
	}








