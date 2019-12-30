// BigNum.h ... LARGE positive integer values

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <ctype.h>
#include "BigNum.h"

// Initialise a BigNum to N bytes, all zero
void initBigNum(BigNum *n, int Nbytes)
{
   int i;
   //printf("1\n");
  // n = malloc(sizeof(BigNum));
  
   n->nbytes = Nbytes;
   n->bytes = malloc(Nbytes * sizeof(Byte));
   for (i = 0 ; i < n->nbytes; i++) {
   		n->bytes[i] = '0';
   }
  //printf("%s\n", n->bytes);
   //assert(sizeof(n) == Nbytes * sizeof(BigNum));
   return;
}

// Add two BigNums and store result in a third BigNum
void addBigNums(BigNum n, BigNum m, BigNum *res)
{
   int i, jw = 0, digit = 0, fg = 0;
   if (res->nbytes < n.nbytes + m.nbytes) {
   		fg = res->nbytes;
		res->nbytes = n.nbytes + m.nbytes;
		res->bytes = realloc(res->bytes, (n.nbytes + m.nbytes) * sizeof(Byte));
		for (i = fg; i < res->nbytes; i++) {
			res->bytes[i] = '0';
		}
	}
   for (i = 0 ; i < n.nbytes; i++) {
   	 res->bytes[i] = n.bytes[i];
   }
   for (i = 0 ; i < m.nbytes; i++) {
     digit = ((m.bytes[i] - '0') + (res->bytes[i] - '0') + jw) % 10;
   	 jw = ((m.bytes[i] - '0') + (res->bytes[i] - '0') + jw) / 10;
   	 res->bytes[i] = digit + '0';
   }
   for (i = m.nbytes; i < res->nbytes; i++) {
   	 digit = ((res->bytes[i] - '0') + jw) % 10;
   	 jw = ((res->bytes[i] - '0') + jw) / 10;
   	 res->bytes[i] = digit + '0';
   }
   return;
}

// Set the value of a BigNum from a string of digits
// Returns 1 if it *was* a string of digits, 0 otherwise
int scanBigNum(char *s, BigNum *n)
{
   int i, fg = 0,k = 0;
  // printf("%s\n", s);
  	if (n->nbytes < strlen(s)) {
		fg = n->nbytes;
		n->nbytes = strlen(s);
		n->bytes = realloc(n->bytes, n->nbytes* sizeof(Byte));
		for (i = fg; i < n->nbytes; i++) {
			n->bytes[i] = '0';
		}
	}
   for (i = 0 ; i < strlen(s); i++) {
   		if (s[strlen(s) - i - 1] > '9' || s[strlen(s) - 1 - i] < '0') {
   			continue;
   		} else {
   			n->bytes[k++] = s[strlen(s) - i - 1];
   			fg = 1;
   		}
   }
   if (fg == 0) {
   	return 0;
   }
  // printf("%s\n", n->bytes);
   return 1;
}

// Display a BigNum in decimal format
void showBigNum(BigNum n)
{
   int fg = -1, i = n.nbytes - 1;
   while (i >= 0) {
   	  if (n.bytes[i] != '0') {
   	     fg = i;
   	     break;
   	  }
   	  i--;
   }
   
   for (i = fg; i >= 0 ; i--) {
   	printf("%c", n.bytes[i]);
   }
   if (fg == -1) {
   	 printf("0");
   }
   return;
}

void multiplyBigNums(BigNum n, BigNum m, BigNum *res) {
	int i, j, jw = 0, fg = 0;
	if (res->nbytes < n.nbytes + m.nbytes) {
		fg = res->nbytes;
		res->nbytes = n.nbytes + m.nbytes;
		res->bytes = realloc(res->bytes, (n.nbytes + m.nbytes) * sizeof(Byte));
		for (i = fg; i < res->nbytes; i++) {
			res->bytes[i] = '0';
		}
	}
	int *ans = malloc(sizeof(int) * res->nbytes); 
	for (i = 0 ; i < n.nbytes; i++) {
		for (j = 0 ; j < m.nbytes; j++) {
			ans[i+j] = ans[i+j] + (n.bytes[i] - '0') * (m.bytes[j] - '0');
		}
	}
	
	for (i = 0 ; i < res->nbytes; i++) {
		j = (ans[i] + jw) % 10;
		jw = (ans[i] + jw) / 10;
		ans[i] = j; 
	}
	
	for (i = 0 ; i < res->nbytes; i++) {
		res->bytes[i] = ans[i] + '0';
	}
	free(ans);
}

void minusBigNums(BigNum n, BigNum m, BigNum *res) {
	int i, fg = 0, jw = 0, data = 0;
	for (i = n.nbytes - 1; i >= 0; i--) {
		if (n.bytes[i] > m.bytes[i]) {
			fg = 1;
			break;
		} else if (m.bytes[i] > n.bytes[i]){
			fg = 2;
		}
	}
	
	if (fg == 0) {
		return;
	}
	
	if (fg == 1) {
		for (i = 0; i <= n.nbytes - 1; i++) {
			if (jw + (n.bytes[i] - '0') >= (m.bytes[i] - '0')) {
				data = jw + (n.bytes[i] - '0') - (m.bytes[i] - '0');
				jw = 0;
				res->bytes[i] = data + '0';
			} else {
				data = 10 + jw + (n.bytes[i] - '0') - (m.bytes[i] - '0');
				jw = -1;
				res->bytes[i] = data + '0';
			}
		}
	} else {
		for (i = 0 ; i <= m.nbytes - 1; i++) {
			if (jw + (m.bytes[i] - '0') >= (n.bytes[i] - '0')) {
				data = jw + (m.bytes[i] - '0') - (n.bytes[i] - '0');
				jw = 0;
				res->bytes[i] = data + '0';
			} else {
				data = 10 + jw + (m.bytes[i] - '0') - (n.bytes[i] - '0');
				jw = -1;
				res->bytes[i] = data + '0';
			}
		}
		
		i = m.nbytes - 1;
		while (i >= 0) {
			if (res->bytes[i] != '0') {
				res->bytes[i+1] = '-';
				break;
			}
			i--;
		}
	}
}
