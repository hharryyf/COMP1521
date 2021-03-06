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
	int pipefd[2];
	char *args1[] = {"/bin/ls", "-l", NULL};
	char *args2[] = {"/usr/bin/wc", "-l", NULL};
	pipe(pipefd);   // [0] read end; [1] write end
	id = fork();
	if (id != 0) {
		close(pipefd[1]);
		wait(&stat);
		dup2(pipefd[0], 0);
		close(pipefd[0]);
		execve("/usr/bin/wc", args2, NULL);
	} else {
		close(pipefd[0]);
		dup2(pipefd[1], 1);
		close(pipefd[1]);
		execve("/bin/ls", args1, NULL);
		exit(1);
	}
	return 0;
}
