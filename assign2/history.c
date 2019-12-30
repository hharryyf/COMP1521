// COMP1521 18s2 mysh ... command history
// Implements an abstract data object

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <signal.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <glob.h>
#include <assert.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include "history.h"

// This is defined in string.h
// BUT ONLY if you use -std=gnu99
//extern char *strdup(const char *s);

// Command History
// array of command lines
// each is associated with a sequence number

#define MAXHIST 20
#define MAXSTR  200

#define HISTFILE "/import/cage/2/z5173587/mymysh_history"

typedef struct _history_entry {
   int   seqNumber;
   char  *commandLine;
} HistoryEntry;

typedef struct _history_list {
   int nEntries;
   HistoryEntry commands[MAXHIST];
} HistoryList;

HistoryList CommandHistory;

// initCommandHistory()
// - initialise the data structure
// - read from .history if it exists
int newCommand() {
	return CommandHistory.nEntries == 0 ? 1 : (CommandHistory.commands[CommandHistory.nEntries - 1].seqNumber + 1) ;
}

int initCommandHistory()
{
	// int fd;
	char *file = strdup(getenv("HOME"));
	// printf("%s\n", file);
	file = realloc(file, strlen(file) + 20);
	strcat(file, "/.mymysh_history"); 
	// printf("%s\n", file);
	FILE *fp = fopen(file, "r");
	if (fp == NULL) {
		// fclose(fp);
		fp = fopen(file, "w+");
		// close(fd);
	}
	char line[MAXSTR + 4];
	int i = 0;
	
	if (fp == NULL) {
		perror("fopen");
		free(file);
		return 0;
	}
	// make the history entry to be zero
	CommandHistory.nEntries = 0;
   	while (fgets(line, MAXSTR, fp) != NULL) {
   		CommandHistory.commands[i].commandLine = calloc(strlen(line) + 2, sizeof(char));
   		sscanf(line, "%d %[^\n]s", &CommandHistory.commands[i].seqNumber, CommandHistory.commands[i].commandLine);
   		CommandHistory.nEntries++; // fix the history entry
   		i++;
   	}	
   	fclose(fp);
   	if (i == 0) {
   		free(file);
   		return 1;
   	}
   	free(file);
   	return CommandHistory.commands[i - 1].seqNumber + 1;   
}

// addToCommandHistory()
// - add a command line to the history list
// - overwrite oldest entry if buffer is full

void addToCommandHistory(char *cmdLine, int seqNo)
{
	
   // TODO
   int i;
   if (CommandHistory.nEntries < MAXHIST) {
   	    CommandHistory.commands[CommandHistory.nEntries].commandLine = strdup(cmdLine);
   	    CommandHistory.commands[CommandHistory.nEntries].seqNumber = seqNo;
   	    CommandHistory.nEntries++;
   } else {
   		for (i = 0 ; i < MAXHIST - 1; i++) {
   			 free(CommandHistory.commands[i].commandLine);
   			 CommandHistory.commands[i].commandLine = strdup(CommandHistory.commands[i+1].commandLine);
   			 CommandHistory.commands[i].seqNumber = CommandHistory.commands[i+1].seqNumber;
   		}
   		free(CommandHistory.commands[CommandHistory.nEntries - 1].commandLine);
   		CommandHistory.commands[CommandHistory.nEntries - 1].commandLine = strdup(cmdLine);
   	    CommandHistory.commands[CommandHistory.nEntries - 1].seqNumber = seqNo;
   }
}

// showCommandHistory()
// - display the list of 

void showCommandHistory(FILE *outf)
{
   int i;
   for (i = 0 ; i < CommandHistory.nEntries; i++) {
   		fprintf(outf, " %3d %s\n", CommandHistory.commands[i].seqNumber, CommandHistory.commands[i].commandLine);
   }
   // TODO
}

// getCommandFromHistory()
// - get the command line for specified command
// - returns NULL if no command with this number

char *getCommandFromHistory(int cmdNo)
{
	int i;
	char *str;
	for (i = 0 ; i <  CommandHistory.nEntries; i++) {
		if (CommandHistory.commands[i].seqNumber == cmdNo) {
			str = strdup(CommandHistory.commands[i].commandLine);
			return str;
		}
	}
	return NULL;// default case just in case no such history command
   // TODO
}

// saveCommandHistory()
// - write history to $HOME/.mymysh_history

void saveCommandHistory()
{
	char *file = strdup(getenv("HOME"));
	file = realloc(file, strlen(file) + 20);
	strcat(file, "/.mymysh_history"); // append the HOME with the invisable file name
	FILE *fp = fopen(file, "w");
	int i;
	if (fp == NULL) {
		perror("fopen");
		free(file);
		return;
	}
	for (i = 0 ; i <  CommandHistory.nEntries; i++) {
		fprintf(fp," %3d %s\n", CommandHistory.commands[i].seqNumber, CommandHistory.commands[i].commandLine);
	}
	free(file);
	fclose(fp);
   // TODO
}

// cleanCommandHistory
// - release all data allocated to command history

void cleanCommandHistory()
{
   //	printf("%d\n", CommandHistory.nEntries);
   int i;
	for (i = 0; i < CommandHistory.nEntries; i++) {
		free(CommandHistory.commands[i].commandLine);
	}
	CommandHistory.nEntries = 0;
   // TODO
}

