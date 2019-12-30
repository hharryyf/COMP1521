#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
int main(void)
{
   pid_t id;  int stat;
   if ((id = fork()) != 0) {
      printf("A = %d\n", id);
     //  printf("C = %d\n", getppid());
      // printf("%d\n", wait(&stat));
      //printf("%d\n", stat);
    //	exit(1);
      return 1;
   }
   else {
   	//	printf("i am the child\n");
   	 // printf("%d\n", id);
   	 //printf("haha %d\n", wait(&stat));
       printf("B = %d\n", getppid());
      return 0;
   }
}
