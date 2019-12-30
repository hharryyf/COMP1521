#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>

int main() {
	int fd = open("test_file.txt", O_RDWR);
	int a[4] = {1,5,2,13};
	int c;
	int b;
	int d;
	// read(fd, &a, 1);
	write(fd, a, sizeof(a));
	lseek(fd, sizeof(int) * 2, SEEK_SET);
	read(fd, &c, sizeof(int));
	b = c + 1;
	// printf("%d\n", b);
	lseek(fd, sizeof(int) * 2, SEEK_SET);
	write(fd, &b, sizeof(b));
    lseek(fd, sizeof(int) * 2, SEEK_SET);
	read(fd, &c, sizeof(int));
    printf("%d\n", c);
	// lseek(fd, sizeof())
	//lseek(fd, sizeof(a) + 4, SEEK_SET);
	//write(fd, c, sizeof(c));
	//lseek(fd, sizeof(a) + 4, SEEK_SET);
	
	//read(fd, &b, sizeof(int));
	//printf("%d\n", b);
	close(fd);
	return 0;
}
