#include <stdio.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
	FILE *pp = popen("pwd", "r");
	if (pp == NULL) {
		return 1;
	}
	char buf[BUFSIZ];
	fgets(buf, BUFSIZ, pp);
	printf("%s\n", buf);
	pclose(pp);
	return 0;
}
