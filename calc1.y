%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "pilha.c"

void yyerror(char *c);
int yylex(void);

%}

%token INT PARENTESISABRE PARENTESISFECHA SOMA EOL MULT SUB
%left SOMA
%left SUB
%left MULT
%left DIV

%%

PROGRAMA:
        PROGRAMA EXPRESSAO EOL { printf("Resultado: %d\n", $2); }
        |
        ;


EXPRESSAO:
    INT { $$ = $1;
        KVPair token;
        strcpy(token.key, available());
        token.value = $1;
        push(token);
        printf("MOV %s,#%d\n", token.key,$1);
    }

    | PARENTESISABRE EXPRESSAO PARENTESISFECHA {
        $$ = $2;
    }
    | EXPRESSAO MULT EXPRESSAO  {
        KVPair token;
        strcpy(token.key, available());
        KVPair r1 = pop($1);
        KVPair r2 = pop($3);
        token.value = r1.value*r2.value;
        printf("MUL %s, %s, %s\n", token.key,r1.key,r2.key);
        push(token);
        $$ = $1 * $3;
    }
    | EXPRESSAO DIV EXPRESSAO  {
        char registrador[5];
        sprintf(registrador, "R%d", top+1);
        KVPair r1 = pop($1);
        KVPair r2 = pop($3);
        KVPair token;
        strcpy(token.key, registrador);
        token.value = r1.value*r2.value;
        printf("MUL %s, %s, %s\n", registrador,r1.key,r2.key);
        push(token);
        $$ = $1 / $3;
    }
    | EXPRESSAO SOMA EXPRESSAO  {
        KVPair token;
        strcpy(token.key, available());
        KVPair r1 = pop($1);
        KVPair r2 = pop($3);
        token.value = r1.value+r2.value;
        printf("ADD %s, %s, %s\n", token.key,r1.key,r2.key);
        push(token);
        $$ = $1 + $3;
    }
    | EXPRESSAO SUB EXPRESSAO  {
        KVPair token;
        strcpy(token.key, available());
        KVPair r1 = pop($1);
        KVPair r2 = pop($3);
        token.value = r1.value-r2.value;
        printf("SUB %s, %s, %s\n", token.key,r1.key,r2.key);
        push(token);
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
