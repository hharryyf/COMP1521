// where_are_the_bits.c ... determine bit-field order
// COMP1521 Lab 03 Exercise
// Written by ...

#include <stdio.h>
#include <stdlib.h>

struct _bit_fields {
   unsigned int a : 20,
                b : 4,
                c : 8;
};

int main(void)
{
   struct _bit_fields x = {3,2,1};
   unsigned int *p = (unsigned int *) &x; 
   int i, curr = 1;
   for (i = 0; i < 32; i++) {
   		if ((curr & *p) > 0) {
   			printf("%d 1\n", i);
   		} else {
   			printf("%d 0\n", i);
   		}
   		curr = curr << 1;
   }   // backward
   return 0;
}
