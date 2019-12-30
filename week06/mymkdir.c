#include <sys/types.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/stat.h>

int main() {
	mkdir("newdir2", 0777);
	return 0;
}
