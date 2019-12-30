// mymysh.c ... a small shell
// Started by John Shepherd, September 2018
// Completed by z5173587, September/October 2018

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <signal.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <glob.h>
#include <assert.h>
#include <fcntl.h>
#include "history.h"
 
// This is defined in string.h
// BUT ONLY if you use -std=gnu99
//extern char *strdup(char *);

// Function forward references

void trim(char *);
int strContains(char *, char *);
char **tokenise(char *, char *);
char **fileNameExpand(char **);
void freeTokens(char **);
char *findExecutable(char *, char **);
int isExecutable(char *);
void prompt(void);


// Global Constants

#define MAXLINE 200

// Global Data

/* none ... unless you want some */
void execute(char **args, char **path, char **envp, char line[]);
int history_substitution(char line[]);
// Main program
// Set up enviroment and then run main loop
// - read command, execute command, repeat

int main(int argc, char *argv[], char *envp[])
{
   
   char **path; // array of directory names
   char **args;  // array of command line arguments
   int cmdNo;   // command number
   int i;       // generic index
   int sub;
  
  // char *str;
   // set up command PATH from environment variable
   for (i = 0; envp[i] != NULL; i++) {
      if (strncmp(envp[i], "PATH=", 5) == 0) break;
   }
   if (envp[i] == NULL)
      path = tokenise("/bin:/usr/bin",":");
   else
      // &envp[i][5] skips over "PATH=" prefix
      path = tokenise(&envp[i][5],":");
#ifdef DBUG
 //  for (i = 0; path[i] != NULL;i++)
 //     printf("path[%d] = %s\n",i,path[i]);
#endif
   //path = fileNameExpand(path);
   // initialise command history
   // - use content of ~/.mymysh_history file if it exists

   cmdNo = initCommandHistory();

   // main loop: print prompt, read line, execute command

   char line[MAXLINE];
   char buff[BUFSIZ];
   prompt();
   while (fgets(line, MAXLINE, stdin) != NULL) {
	   	  //  printf("%d\n", getpid());
		  trim(line); // remove leading/trailing space
		  // empty command case
		  sub = 1;
		  if (strcmp(line, "") == 0) {
			    prompt();
			 	continue;
		  }
		  // exit command case
		  if (strcmp(line, "exit") == 0) {
		  		break;
		  }
		  // substiution
		  if (line[0] == '!') {
		  	 	sub = history_substitution(line);
		  		if (sub == 0) {
		  		    prompt();
		  			continue;
		  		} else {
		  			printf("%s\n", line);
		  		}
		  }
		  // tokenise and then file expansion
		  args = tokenise(line, " ");
		  args = fileNameExpand(args);
		  // dealing with history
		  if (strcmp(args[0], "h") == 0 || strcmp(args[0], "history") == 0) {
		  		cmdNo = newCommand();   
		  		showCommandHistory(stdout);
		  		addToCommandHistory(line, cmdNo);
		  } else if (strcmp(args[0], "pwd") == 0){  // dealing with pwd
		  		if (getcwd(buff, BUFSIZ) == NULL) {  
		  			perror("pwd");
		  		} else {
		  			printf("%s\n", buff);    // show the current pwd
		  			cmdNo = newCommand();
		  			addToCommandHistory(line, cmdNo);
		  		}
		  } else if (strcmp(args[0], "cd") == 0) {
			    // change the directory cd case
			    if (getcwd(buff, BUFSIZ) == NULL) {  // dealing with PWD
		  			perror("pwd");
		  		} else {
		  		    if (args[1] == NULL) {
		  		    	if(chdir(getenv("HOME")) == -1) {
		  		    		perror("cd");
		  		    	} else {
		  		    		if (getcwd(buff, BUFSIZ) == NULL) {  // dealing with PWD
			  					perror("pwd");
			  				} else {
			  					printf("%s\n", buff);
			  					cmdNo = newCommand();
			  					addToCommandHistory(line, cmdNo);
			  				}
		  		    	}	
		  		    } else {
		  		    	if (chdir(args[1]) == -1) {  // error on cd
			  				perror(args[1]);
			  			} else {
			  				if (getcwd(buff, BUFSIZ) == NULL) {  
			  					// dealing with PWD
			  					perror("pwd");
			  				} else {
			  					printf("%s\n", buff);
			  					cmdNo = newCommand();
			  					addToCommandHistory(line, cmdNo);
			  				}
			  			}
		  			}
		  			
		  		}
		  } else {
		  		execute(args, path, envp, line);	
		  }
		  // free the associated memory of token
		  freeTokens(args); 
		  prompt();
		  strcpy(line, ""); // make the line as "", in case it is not NUll terminated
   }
   // only when normal exit save command history and leave
   // if (strcmp(line, "") == 0) {
   saveCommandHistory();
   // showCommandHistory(stdout);
   cleanCommandHistory(); 
   freeTokens(path);  // free the path token to prevent memory leak
   printf("\n");
   return 0;
}
// dealing with history substitution
int history_substitution(char line[]) {
	char *str;
	int cmdNo;
	// only one ! leave
	if (strlen(line) == 1) {
		fprintf(stderr, "Invalid history substitution\n");
		return 0;
	}
	
	if ((line[1] > '9' || line[1] < '0') && line[1] != '!') {
		fprintf(stderr, "Invalid history substitution\n");
		return 0;
	}
	// with double !! try to substitute the command history - 1
	if (line[1] == '!') {
		cmdNo = newCommand() - 1;   // get the newComand num - 1
	    str = getCommandFromHistory(cmdNo);   // try to get the string
	    if (str != NULL) {
	    	strcpy(line, str);    // if it is not NULL performs substitution
	    	free(str);
	    } else {    // print no such command
	    	fprintf(stderr, "No command #%d\n", cmdNo);
	    	return 0;
	    }
	} else {
		// try to atoi the command num from the line
		cmdNo = atoi(line + 1);
		str = getCommandFromHistory(cmdNo);  // get the number
	    if (str != NULL) {   // if has such number exist
	    	strcpy(line, str);  // performs substitution
	    	free(str);
	    } else {  // print the error message
	    	fprintf(stderr, "No command #%d\n", cmdNo);
	    	return 0;
	    }
	}
	return 1;
}

// fileNameExpand: expand any wildcards in command-line args
// - returns a possibly larger set of tokens
char **fileNameExpand(char **tokens) {
	
   	char **string = NULL;
	int i = 0, j = 0, k = 0, n;
	glob_t command;
	char buf[BUFSIZ], tmp[BUFSIZ];
    int total_size = 0;
    getcwd(buf, BUFSIZ);   // get the path   
	i = 0;
	n = 0;
	int find = 0;
	while (tokens[i] != NULL) {
		getcwd(buf, BUFSIZ);
		find = 0;
		for (j = 0 ; j < strlen(tokens[i]); j++) {
		     
		     if (tokens[i][0] == '~') {
		     	sprintf(buf, "%s", tokens[i]);
		     	// glob all the possible substitution
		     	glob(buf, GLOB_NOCHECK | GLOB_TILDE, NULL, &command); 
		     	for (k = 0 ; k < command.gl_pathc; k++) {
    				string = realloc(string, (++total_size + 1) * sizeof(char *));
    				string[n] = NULL;  
    				// realloc space for the new command
    				string[n++] = strdup(command.gl_pathv[k]);
    				string[n] = NULL;
    			}
				find = 1;
				globfree(&command);
			 	break;
		     }
		     
    	   	 if (tokens[i][j] == '*' || tokens[i][j] == '[' || tokens[i][j] == '?')  {               
    	   	    strcpy(tmp, tokens[i]);
    			// glob all the possible substitution
    			glob(tmp, GLOB_NOCHECK | GLOB_TILDE, NULL, &command);
    			for (k = 0 ; k < command.gl_pathc; k++) {
    				getcwd(buf, BUFSIZ);
    				string = realloc(string, (++total_size + 1) * sizeof(char *));
    				string[n] = NULL;
    				// realloc space for the new command
    				string[n++] = strdup(command.gl_pathv[k]);
    				string[n] = NULL;
    			}
				find = 1;
				globfree(&command);
			 	break;
			 } 
		}
		
		if (find == 0) {
			string = realloc(string, (++total_size + 1) * sizeof(char *));
			string[n] = NULL;
			string[n++] = strdup(tokens[i]);
			string[n] = NULL;
		}
		i++;
	}
	freeTokens(tokens);
	string[total_size] = NULL;
	return string;
}

// findExecutable: look for executable in PATH
char *findExecutable(char *cmd, char **path)
{
      char executable[MAXLINE];
      executable[0] = '\0';
      if (cmd[0] == '/' || cmd[0] == '.') {
         strcpy(executable, cmd);
         if (!isExecutable(executable))
            executable[0] = '\0';
      }
      else {
         int i;
         for (i = 0; path[i] != NULL; i++) {
            sprintf(executable, "%s/%s", path[i], cmd);
            if (isExecutable(executable)) break;
         }
         if (path[i] == NULL) executable[0] = '\0';
      }
      if (executable[0] == '\0')
         return NULL;
      else
         return strdup(executable);
}


// execute: run a program, given command-line args, path and envp
void execute(char **args, char **path, char **envp, char line[])
{
   int i, total_command = 0;
   pid_t pid;   // pid of child process
   int stat;    // return status of child
   char *command;
   int cmdNo, sub = -1;
   int fd;
   int place = -1;
   int redirection = 0;
   int find = 0;
   int total_redirection = 0;
   i = 0;
   while (args[i] != NULL) {
   	    if (strcmp(args[i], "<") == 0) {
   			find++;  // count the number of < or >
   			place = i;  // i stand for the index of the current '<' or '>'
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
   total_redirection = find;
   find = 0;
   // try to find the executable command
   command = findExecutable(args[0], path);
   
   // have a bool value of find
   if (command != NULL) {
   	   find = 1;
   }  else {
   	   find= 0;
   }
   		
   // the parent process
   if (redirection != 0) {
	   	if (total_redirection > 1 || total_command - place != 2 || total_command <= 2) {
	   	  	printf("Invalid i/o redirection\n");
	   	  	free(command);
	   	  	return;
	   	} else {
	   		if (redirection == 1) {
	   			fd = open(args[total_command - 1], O_RDONLY, 0644);
	   		} else {
	   			 fd = open(args[total_command - 1], O_RDWR | O_TRUNC | O_CREAT, 0644);
	   		}
	   		// invalid input file	
	   		if (fd == -1 && redirection == 1) {
	   			perror("Input redirection");
	   			free(command);
	   			return;
	   		}
	   		// invalid output file
	   		if (fd == -1 && redirection == 2) {
	   			perror("Output redirection");
	   			free(command);
	   			return;
	   		}
	   		
	   	}
   	}
   	
   	if (find == 0) {
	   	printf("%s: ", args[0]);
	   	printf("Command not found\n");
	   	free(command);
	   	return;
   	}
   		
   	pid = fork();
   	if (pid == -1) {
   		perror("fork");
   	}
   	
	if (pid != 0) {
		wait(&stat);
		sub = WEXITSTATUS(stat);
		// get the return value of the command
		printf("--------------------\nReturns %d\n", sub);
		// if (sub == 0) {
		cmdNo = newCommand();
	  	addToCommandHistory(line, cmdNo);
	  	// } 
			
		if (redirection != 0) {
			close(fd);
		}
		
		free(command);
	} else {		 
		// redirect output case
		if (redirection == 2) {
			printf("Running %s ...\n--------------------\n", command);
			dup2(fd, 1);
			close(0);		
   			free(args[total_command - 1]);
   			free(args[total_command - 2]);
   			args[total_command - 1] = NULL;
   			args[total_command - 2] = NULL;
   			execve(command, args, envp);
		} else if (redirection == 1) {   
			// redirect input case
			printf("Running %s ...\n--------------------\n", command);
			dup2(fd, 0);
			free(args[total_command - 1]);
   			free(args[total_command - 2]);
   			args[total_command - 1] = NULL;
   			args[total_command - 2] = NULL;
   			execve(command, args, envp);
		} else {   
			// other case just simply execve
			printf("Running %s ...\n--------------------\n", command);
   			execve(command, args, envp);
   		}
   			perror(command);
   			exit(errno);
	}
   
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

// strContains: does the first string contain any char from 2nd string?
int strContains(char *str, char *chars)
{
   for (char *s = str; *s != '\0'; s++) {
      for (char *c = chars; *c != '\0'; c++) {
         if (*s == *c) return 1;
      }
   }
   return 0;
}

// prompt: print a shell prompt
// done as a function to allow switching to $PS1
void prompt(void)
{
   printf("mymysh$ ");
}
