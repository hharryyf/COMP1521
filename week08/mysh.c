// mysh.c ... a minimal shell
// Started by John Shepherd, October 2017
// Completed by <<YOU>>, September 2018

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

// this next line may not be needed on you machine
// comment it out if it generates an error
extern char *strdup(char *);

void trim(char *);
char **tokenise(char *, char *);
void freeTokens(char **);
int isExecutable(char *);
void execute(char **, char **, char **, char *);

int main(int argc, char *argv[], char *envp[])
{
  // pid_t pid;   // pid of child process
  // int stat;    // return status of child
   char **path; // array of directory names
   char **args;  // array of command line arguments
   // set up command PATH from environment variable
   int i;
   for (i = 0; envp[i] != NULL; i++) {
   	  printf("%s\n", envp[i]);
      if (strncmp(envp[i], "PATH=", 5) == 0) break;
   }
   if (envp[i] == NULL)
      path = tokenise("/bin:/usr/bin",":");
   else
      // &envp[i][5] skips over "PATH=" prefix
      path = tokenise(&envp[i][5],":");

#ifdef DBUG
   for (i = 0; path[i] != NULL;i++)
      printf("dir[%d] = %s\n",i,path[i]);
#endif

   // main loop: print prompt, read line, execute command
   char line[BUFSIZ];
   printf("mysh$ ");
   while (fgets(line, BUFSIZ, stdin) != NULL) {
      trim(line); // remove leading/trailing space
      printf("%s\n", line);
      if (strcmp(line,"exit") == 0) break;
      if (strcmp(line,"") == 0) { printf("mysh$ "); continue; }
	  args = tokenise(line, " ");
	  
	  	execute(args, path, envp, line);
	  //	freeTokens(args);
	  				       // the child process	
      // TODO: implement the tokenise/fork/execute/cleanup code

      printf("mysh$ ");
   }
   printf("\n");
   return(EXIT_SUCCESS);
}

// execute: run a program, given command-line args, path and envp
void execute(char **args, char **path, char **envp, char line[])
{
   int i, total_command = 0;
   // int find = 0;
   pid_t pid;   // pid of child process
   int stat;    // return status of child
   char *command, *tmp;
   int sub = -1;
   int find  = 0;
   int fd;
   int place = -1;
   int redirection = 0;
   i = 0;
   printf("%s\n", line);
   while (args[i] != NULL) {
   	    printf("arg[%d] =  %s\n", i, args[i]);
   		if (strcmp(args[i], "<") == 0) {
   			find++;
   			place = i;
   			redirection = 1;    // 1 stands for input
   		}
   		
   		if (strcmp(args[i], ">") == 0) {
   			find++;
   			place = i;
   			redirection = 2;   // 2 stands for output
   		}
   		i++;
   }
   
   total_command = i;
   if (redirection != 0) {
	   if (find > 1 || total_command - place != 2) {
	   	  printf("Invalid i/o redirection\n");
	   	  return;
	   } else {
	   		if (redirection == 1) {
	   			fd = open(args[total_command - 1], O_RDONLY);
	   		} else {
	   			// printf("%s\n", args[total_command - 1]);
	   			fd = open(args[total_command - 1], O_WRONLY);
	   		}
	   		if (fd == -1) {
	   			perror("Input redirection");
	   			return;
	   		}
	   }
   }
   
   find = 0;
   if (args[0][0] == '.' || args[0][0] == '/') {
   		if (isExecutable(args[0])) {
   			command = strdup(args[0]);
   			find = 1;
   		}
   } else {
   		for (i = 0 ; path[i] != NULL; i++) {
   			tmp = calloc(strlen(path[i]) + strlen(args[0]) + 4, sizeof(char));
   			strcat(tmp, path[i]);
   			tmp[strlen(tmp) + 1] = '\0';
   			tmp[strlen(tmp)] = '/';
   			strcat(tmp, args[0]);
   			if (isExecutable(tmp)) {
   				find = 1;
   				command = strdup(tmp);
   				break;
   			}
   			free(tmp);
   		}   	
   }
   
   if (find == 0) {
   		printf("%s: ", args[0]);
   		printf("Command not found\n");
   		if (redirection != 0) {
   			close(fd);
   		}
   		return;
   } else {
   		// the parent process
		if ((pid = fork()) != 0) {
			wait(&stat);
			sub = WEXITSTATUS(stat);
			printf("--------------------\nReturns %d\n", sub);
			if (redirection != 0) {
				close(fd);
			}
			freeTokens(args);   
		} else {		 
			// the child process
			if (redirection == 2) {
				printf("Running %s ...\n--------------------\n", command);
				dup2(fd, 1);
			    // close(1);
				close(0);
				
   				// printf("%s\n", command);
   				free(args[total_command - 1]);
   				free(args[total_command - 2]);
   				args[total_command - 1] = NULL;
   				args[total_command - 2] = NULL;
   				execve(command, args, envp);
			} else if (redirection == 1) {
				printf("Running %s ...\n--------------------\n", command);
				dup2(fd, 0);
				// close(0);
				// close(1);
				
   				// printf("%s\n", command);
   				free(args[total_command - 1]);
   				free(args[total_command - 2]);
   				args[total_command - 1] = NULL;
   				args[total_command - 2] = NULL;
   				execve(command, args, envp);
			} else {
				printf("Running %s ...\n--------------------\n", command);
   			    printf("%s\n", command);
   				execve(command, args, envp);
   			}
		}
   		
   }
  // free(command);
   // TODO: implement the find-the-executable and execve() it code
  // exit(1);
}


// isExecutable: check whether this process can execute a file
int isExecutable(char *cmd)
{
   struct stat s;
   // must be accessible
   if (stat(cmd, &s) < 0)
      return 0;
   // must be a regular file
   //if (!(s.st_mode & S_IFREG))
   if (!S_ISREG(s.st_mode))
      return 0;
   // if it's owner executable by us, ok
   if (s.st_uid == getuid() && s.st_mode & S_IXUSR)
      return 1;
   // if it's group executable by us, ok
   if (s.st_gid == getgid() && s.st_mode & S_IXGRP)
      return 1;
   // if it's other executable by us, ok
   if (s.st_mode & S_IXOTH)
      return 1;
   return 0;
}

// tokenise: split a string around a set of separators
// create an array of separate strings
// final array element contains NULL
char **tokenise(char *str, char *sep)
{
   // temp copy of string, because strtok() mangles it
   char *tmp;
   // count tokens
   tmp = strdup(str);
   int n = 0;
   strtok(tmp, sep); n++;
   while (strtok(NULL, sep) != NULL) n++;
   free(tmp);
   // allocate array for argv strings
   char **strings = malloc((n+1)*sizeof(char *));
   assert(strings != NULL);
   // now tokenise and fill array
   tmp = strdup(str);
   char *next; int i = 0;
   next = strtok(tmp, sep);
   strings[i++] = strdup(next);
   while ((next = strtok(NULL,sep)) != NULL)
      strings[i++] = strdup(next);
   strings[i] = NULL;
   free(tmp);
   return strings;
}

// freeTokens: free memory associated with array of tokens
void freeTokens(char **toks)
{
   for (int i = 0; toks[i] != NULL; i++)
      free(toks[i]);
   free(toks);
}

// trim: remove leading/trailing spaces from a string
void trim(char *str)
{
   int first, last;
   first = 0;
   while (isspace(str[first])) first++;
   last  = strlen(str)-1;
   while (isspace(str[last])) last--;
   int i, j = 0;
   for (i = first; i <= last; i++) str[j++] = str[i];
   str[j] = '\0';
}
