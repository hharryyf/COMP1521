// COMP1521 18s1 Week 02 Lab
// Add two numbers (numbers can be LARGE)

#include <stdio.h>
#include "BigNum.h"

int main(int argc, char **argv)
{
   BigNum num1;  // first input number
   BigNum num2;  // second input number
   BigNum sum;   // num1 + num2
   BigNum product;
   if (argc < 3) {
      printf("Usage: %s Num1 Num2\n", argv[0]);
      return 1;
   }

   // Initialise BigNum objects
   initBigNum(&num1, 120);
   initBigNum(&num2, 120);
   initBigNum(&sum,  120);
   initBigNum(&product, 120);
   //printf("%s\n", num1.bytes);
   // Extract values from cmd line args
   if (!scanBigNum(argv[1], &num1)) {
      printf("First number invalid\n");
      return 1;
   }
   if (!scanBigNum(argv[2], &num2)) {
      printf("Second number invalid\n");
      return 1;
   }

   // Add num1+num2, store result in sum
  /* addBigNums(num1, num2, &sum);

   printf("Sum of "); showBigNum(num1);
   printf("\nand "); showBigNum(num2);
   printf("\nis "); showBigNum(sum);
   printf("\n");
   */
   // multiply num1+num2, store result in product
   multiplyBigNums(num1, num2, &product);

   printf("Product of "); showBigNum(num1);
   printf("\nand "); showBigNum(num2);
   printf("\nis "); showBigNum(product);
   printf("\n");
   return 0;

}
