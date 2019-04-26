%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "reg_mapper.c"

void yyerror(char *c);
int yylex(void);

%}

%token INT PARENTESISABRE PARENTESISFECHA SOMA SUB MULT EOL
%left SOMA
%left SUB
%left MULT
%left DIV

%%

PROGRAMA:
        PROGRAMA EXPRESSAO EOL {
            printf("Resultado: %d\n", $2);
            printstack();
        }
        |
        ;


EXPRESSAO:
    INT {
        $$ = $1;
        KVPair token;
    }

    | PARENTESISABRE EXPRESSAO PARENTESISFECHA {
        $$ = $2;
    }
    | EXPRESSAO MULT EXPRESSAO  {
        KVPair token;
        KVPair r1 = pop($1);
        KVPair r2 = pop($3);
        if(r1.value == -1) {
            strcpy(r1.key, available());
            r1.value = $1;
            printf("MOV %s,#%d\n", r1.key,$1);
            push(r1);
            r1.used = true;
        }
        if(r2.value == -1) {
            strcpy(r2.key, available());
            r2.value = $3;
            printf("MOV %s,#%d\n", r2.key,$3);
            push(r2);
            r2.used = true;
        }
        strcpy(token.key, available());
        token.value = $1*$3;
        push(token);
        printf("MUL %s, %s, %s\n", token.key,r1.key,r2.key);
        if(r1.used){
            pop($1);
        }
        if(r2.used){
            pop($3);
        }
        $$ = $1 * $3;
    }
    | EXPRESSAO SOMA EXPRESSAO  {
        KVPair token;
        KVPair r1 = pop($1);
        KVPair r2 = pop($3);
        if(r1.value == -1) {
            strcpy(r1.key, available());
            r1.value = $1;
            printf("MOV %s,#%d\n", r1.key,$1);
            push(r1);
            r1.used = true;
        }
        if(r2.value == -1) {
            strcpy(r2.key, available());
            r2.value = $3;
            printf("MOV %s,#%d\n", r2.key,$3);
            push(r2);
            r2.used = true;
        }
        strcpy(token.key, available());
        token.value = $1+$3;
        push(token);
        printf("ADD %s, %s, %s\n", token.key,r1.key,r2.key);
        if(r1.used){
            pop($1);
        }
        if(r2.used){
            pop($3);
        }
        $$ = $1 + $3;
    }
    | EXPRESSAO SUB EXPRESSAO  {
        KVPair token;
        KVPair r1 = pop($1);
        KVPair r2 = pop($3);
        if(r1.value == -1) {
            strcpy(r1.key, available());
            r1.value = $1;
            printf("MOV %s,#%d\n", r1.key,$1);
            push(r1);
            r1.used = true;
        }
        if(r2.value == -1) {
            strcpy(r2.key, available());
            r2.value = $3;
            printf("MOV %s,#%d\n", r2.key,$3);
            push(r2);
            r2.used = true;
        }
        strcpy(token.key, available());
        token.value = $1-$3;
        push(token);
        printf("SUB %s, %s, %s\n", token.key,r1.key,r2.key);
        if(r1.used){
            pop($1);
        }
        if(r2.used){
            pop($3);
        }
        $$ = $1 - $3;
    }
    ;

%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main() {
  for(int i = 0; i<MAXSIZE;i++){
     KVPair data;
     data.used = false;
     data.value = 0;
     char registrador[5];
     sprintf(registrador, "R%d", i);
     strcpy(data.key, registrador);
     stack[i] = data;
  }
  yyparse();
  return 0;

}
