#include <stdio.h>
#include <stdbool.h>

typedef struct {
    char key[5];
    int value;
    bool used;
} KVPair;

int MAXSIZE = 12;
KVPair stack[12];

KVPair pop(int value) {
   KVPair data;
    data.value = -1;
   for(int i = 0; i<MAXSIZE;i++){
      if(stack[i].value == value && stack[i].used == true) {
         data = stack[i];
         stack[i].used = false;
         break;
      }
   }
   return data;
}

KVPair get(int value) {
    KVPair data;
    data.value = -1;
    for(int i = 0; i<MAXSIZE;i++){
        if(stack[i].value == value && stack[i].used == true) {
            data = stack[i];
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

void emptystack() {
    for(int i = 0; i<MAXSIZE;i++){
        stack[i].value=0;
        stack[i].used = false;
    }
}
