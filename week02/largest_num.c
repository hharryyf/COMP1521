#include <stdio.h>
#include <stdlib.h>
int main() {
    int i;
    for (i = 10000000; ;i++) {
    	if (i + 1 < i) {
    		printf("%d\n", i);
    		return 0;
    	}
    }
	return 0;
}
