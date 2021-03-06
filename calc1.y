%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "reg_mapper.c"

void yyerror(char *c);
int mult = 0;
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
            KVPair result = get($2);
            if(result.value==-1){
                printf("            MOV R0, %d\n", $2);
                strcpy(result.key, available());
                result.value = $2;
                push(result);
            } else{
                if(strcmp(result.key,"R0") != 0){
                    result = pop($2);
                    printf("            MOV R0, %s\n", result.key);
                    strcpy(result.key, available());
                    push(result);
                }
            }
            
            printf("Registradores resultantes:\n");
            printstack();
            emptystack();
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
    | SUB INT {
        $$ = -1*$2;
    }
    | EXPRESSAO MULT EXPRESSAO  {
        KVPair token;
        KVPair sinal;
        KVPair r1 = get($1);
        KVPair r2 = get($3);
        if(r1.value == -1) {
            strcpy(r1.key, available());
            r1.value = $1;
            printf("            MOV %s, #%d\n", r1.key,$1);
            push(r1);
            r1.used = true;
        }
        if(r2.value == -1) {
            strcpy(r2.key, available());
            r2.value = $3;
            printf("            MOV %s, #%d\n", r2.key,$3);
            push(r2);
            r2.used = true;
        }
        strcpy(token.key, available());
        
        token.value = $1*$3;
        push(token);
        strcpy(sinal.key, available());
        sinal.value = 0;
        push(sinal);
        printf("            MOV %s, #0\n", sinal.key);
        printf("            MOV %s, #0\n", token.key);
        printf("            CMP %s, #0\n", r1.key);
        printf("            BEQ zero%d\n", mult);
        printf("            CMP %s, #0\n", r2.key);
        printf("            BEQ zero%d\n", mult);
        printf("            CMP %s, #0\n", r1.key);
        printf("            ADDLT %s, %s, #1\n", sinal.key,sinal.key);
        printf("            MVNLT %s, %s\n", r1.key, r1.key);
        printf("            ADDLT %s, %s, #1\n", r1.key,r1.key);
        printf("            CMP %s, #0\n", r2.key);
        printf("            ADDLT %s, %s, #1\n", sinal.key,sinal.key);
        printf("            MVNLT %s, %s\n", r2.key, r2.key);
        printf("            ADDLT %s, %s, #1\n", r2.key, r2.key);
        printf("comparacao%d CMP %s, #0\n", mult, r1.key);
        printf("            BEQ fim%d\n", mult);
        printf("            ADD %s, %s, %s\n", token.key,token.key,r2.key);
        printf("            SUB %s, %s, #1\n", r1.key,r1.key);
        printf("            B comparacao%d\n", mult);
        printf("zero%d       MOV %s, #0\n", mult, token.key);
        printf("fim%d        CMP %s, #1\n", mult, sinal.key);
        printf("            SUBEQ %s, %s, #1\n", token.key, token.key);
        printf("            MVNEQ %s, %s\n", token.key, token.key);
        mult++;
        if(r1.used){
            pop($1);
        }
        if(r2.used){
            pop($3);
        }
        pop(sinal.value);
        $$ = $1 * $3;
    }
    | EXPRESSAO SOMA EXPRESSAO  {
        KVPair token;
        KVPair r1 = get($1);
        KVPair r2 = get($3);
        if(r1.value == -1) {
            strcpy(r1.key, available());
            r1.value = $1;
            printf("            MOV %s, #%d\n", r1.key,$1);
            push(r1);
            r1.used = true;
        }
        if(r2.value == -1) {
            strcpy(r2.key, available());
            r2.value = $3;
            printf("            MOV %s, #%d\n", r2.key,$3);
            push(r2);
            r2.used = true;
        }
        strcpy(token.key, available());
        token.value = $1+$3;
        push(token);
        printf("            ADD %s, %s, %s\n", token.key,r1.key,r2.key);
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
        KVPair r1 = get($1);
        KVPair r2 = get($3);
        if(r1.value == -1) {
            strcpy(r1.key, available());
            r1.value = $1;
            printf("            MOV %s, #%d\n", r1.key,$1);
            push(r1);
            r1.used = true;
        }
        if(r2.value == -1) {
            strcpy(r2.key, available());
            r2.value = $3;
            printf("            MOV %s, #%d\n", r2.key,$3);
            push(r2);
            r2.used = true;
        }
        strcpy(token.key, available());
        token.value = $1-$3;
        push(token);
        printf("            SUB %s, %s, %s\n", token.key,r1.key,r2.key);
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
