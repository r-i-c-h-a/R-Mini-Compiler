#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "opt.h"

int main(){

FILE *fp;
fp = fopen("output.txt","r");

//printf("-------------------------ICG-------------------------\n");
finalICG(fp);

char *f1[] = {"const_prop1.txt","const_prop2.txt","const_prop3.txt","const_prop4.txt"};
char *f2[] = {"const_fold.txt","const_fold1.txt","const_fold2.txt","const_fold3.txt","final.txt"};

int n = 0;

FILE *fp1;
fp1 = fopen("ICG.txt","r");
FILE *fp2;
fp2 = fopen("const_prop.txt","a");
constant_propagation(fp1,fp2,"ICG.txt");

FILE *fp3;
fp3 = fopen("const_prop.txt","r");
FILE *fp4;
fp4 = fopen("const_fold.txt","a");
constant_folding(fp3,fp4);

while(n<4){
	fp1 = fopen(f2[n],"r");
	fp2 = fopen(f1[n],"a");
	constant_propagation(fp1,fp2,f2[n]);

	fp3 = fopen(f1[n],"r");
	fp4 = fopen(f2[n+1],"a");
	constant_folding(fp3,fp4);
	n+=1;
}

fp1 = fopen("final.txt","r");
//printf("------------Constant Propagation and Constant Folding done 5 times---------------\n");
char chunk[128];
/*while(fgets(chunk, sizeof(chunk), fp1) != NULL) {
	printf("%s\n",strip(chunk));
}*/

fp1 = fopen("final.txt","r");
fp2 = fopen("dead_code_removed.txt","a");
dead_code_elim(fp1,fp2);

fp1 = fopen("dead_code_removed.txt","r");
//printf("------------Dead Code Elimination Done---------------\n");
/*while(fgets(chunk, sizeof(chunk), fp1) != NULL) {
	printf("%s\n",strip(chunk));
}*/

}

