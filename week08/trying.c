#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <signal.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/types.h>
#include <unistd.h>
#include <assert.h>

int main(int argc, char *argv[], char *envp[]) {
	pid_t id;
	int stat;
	freopen("hello.txt", "r", stdin);
	char *args1[] = {"/bin/cat", NULL};
	id = fork();
	if (id != 0) {
		wait(&stat);
	} else {
		execve("/bin/cat", args1, NULL);
		exit(1);
	}
	return 0;
}
