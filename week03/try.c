#include <stdio.h>
#include <stdlib.h>

typedef enum {BLUE, RED, GREEN} typ;

union _all {
   int   ival;
   char cval;
   char  sval[4];
   float fval;
   unsigned int uval;
};

int main() {
	  union _all var;
	  var.uval = 0x00313233;
      printf("%x\n", var.uval);
      printf("%d\n", var.ival);
      printf("%c\n", var.cval);
      printf("%s\n", var.sval);
      printf("%f\n", var.fval);
      printf("%e\n", var.fval);

	typ number;
	
	printf("%d %d\n", BLUE, GREEN);
	return 0;
}

