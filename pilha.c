#include <stdio.h>
#include <stdbool.h>

typedef struct {
    char key[5];
    int value;
    bool used;
} KVPair;

int MAXSIZE = 7;
KVPair stack[7];
int top = -1;

int isempty() {

   if(top == -1)
      return 1;
   else
      return 0;
}

int isfull() {

   if(top == MAXSIZE)
      return 1;
   else
      return 0;
}

KVPair peek() {
   return stack[top];
}

KVPair pop(int value) {
   KVPair data;
   for(int i = 0; i<MAXSIZE;i++){
      if(stack[i].value == value && stack[i].used == true) {
         data = stack[i];
         stack[i].used = false;
         break;
      }
   }
   return data;
}

char * available() {
   static char data[5];
   for(int i = 0; i<MAXSIZE;i++){
      if(!stack[i].used) {
         strcpy(data, stack[i].key);
         break;
      }
   }
   return data;
}

void printstack() {
   static char data[5];
   for(int i = 0; i<MAXSIZE;i++){
      if(stack[i].used) {
          printf("%s %d\n",stack[i].key,stack[i].value);
      }
   }
}

void push(KVPair data) {
   for(int i = 0; i<MAXSIZE;i++){
      if(!stack[i].used) {
         stack[i]=data;
         stack[i].used = true;
         break;
      }
   }
}
