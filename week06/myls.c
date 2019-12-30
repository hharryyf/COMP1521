// myls.c ... my very own "ls" implementation

#include <stdlib.h>
#include <stdio.h>
#include <bsd/string.h>
#include <unistd.h>
#include <fcntl.h>
#include <dirent.h>
#include <grp.h>
#include <pwd.h>
#include <sys/stat.h>
#include <sys/types.h>

#define MAXDIRNAME 100
#define MAXFNAME   200
#define MAXNAME    20
char b[4][3] = {{'-', 'x'}, {'-', 'r'}, {'-', 'w'}};
char *rwxmode(mode_t, char *);
char *username(uid_t, char *);
char *groupname(gid_t, char *);
struct collection {
    char user_name[MAXNAME];
	char file_name[MAXNAME];
	char rwx[12];
	long long size;
	char group_name[MAXNAME];
	char link[MAXNAME];
};

int cmp(const void *pai, const void *paj) {
	struct collection *pa = (struct collection *) pai;
	struct collection *pb = (struct collection *) paj;
	return strcmp(pa->file_name, pb->file_name);
}

int main(int argc, char *argv[])
{
   // string buffers for various names
   char dirname[MAXDIRNAME];
   char uname[MAXNAME+1]; // UNCOMMENT this line
   char gname[MAXNAME+1]; // UNCOMMENT this line
   char mode[MAXNAME+1]; // UNCOMMENT this line
   char slink[MAXNAME+1] = "";
   char *tmp = (char *) calloc(2, sizeof(char));
   // char *tmp2 = (char *) calloc(2, sizeof(char));
   // collect the directory name, with "." as default
   if (argc < 2)
      strlcpy(dirname, ".", MAXDIRNAME);
   else
      strlcpy(dirname, argv[1], MAXDIRNAME);

   // check that the name really is a directory
   struct stat info;
   if (stat(dirname, &info) < 0)
      { perror(argv[0]); exit(EXIT_FAILURE); }
   if ((info.st_mode & S_IFMT) != S_IFDIR)
      { fprintf(stderr, "%s: Not a directory\n",argv[0]); exit(EXIT_FAILURE); }

   // open the directory to start reading
   DIR *df = opendir(dirname);; // UNCOMMENT this line
   // ... TODO ...
   struct dirent *entry;
   struct collection a[10100];
   int n = 0;
   if (df == NULL) {
   	  return 0;
   }
   while ((entry = readdir(df)) != NULL) {
   	  if (entry->d_name[0] != '.') {
   	     tmp = realloc(tmp, strlen(dirname) + strlen(entry->d_name) + 4);
   	     strcat(tmp, dirname);
   	     tmp[strlen(tmp)] = '\0';
   	     tmp[strlen(tmp) + 1] = '\0';
   	     tmp[strlen(tmp)] = '/';
   	     strcat(tmp, entry->d_name);
   	     //sprintf(tmp, "%s/%s", dirname, entry->d_name);
   	     lstat(tmp, &info);
   	     if ((info.st_mode & S_IFMT) == S_IFLNK) {
   	     	readlink(tmp, slink, 101);
   	     	strcpy(a[n].link, slink);
   	     	// printf("%s\n", slink);
   	     }
   	     
   	     strcpy(a[n].file_name, entry->d_name);
   	     strcpy(a[n].user_name, username(info.st_uid, uname));
   	     strcpy(a[n].rwx, rwxmode(info.st_mode, mode));
   	     a[n].size = (long long)info.st_size;
   	     strcpy(a[n].group_name, groupname(info.st_gid, gname));
	     n++;
	     // printf("%d\n", info.st_nlink);
   	 //    printf("%s  %-8.8s %-8.8s %8lld  %s\n", rwxmode(info.st_mode, mode),username(info.st_uid, uname), groupname(info.st_gid, gname), (long long)info.st_size, entry->d_name);
   	  	free(tmp);
   	  	tmp = (char *) calloc(2, sizeof(char));
   	  }
   }
   free(tmp);
   qsort(a, n, sizeof(struct collection), cmp);
   int i;
   for (i = 0 ; i < n; i++) {
   	  printf("%s  %-8.8s %-8.8s %8lld  %s", a[i].rwx,a[i].user_name, a[i].group_name, a[i].size, a[i].file_name);
   	  if (a[i].rwx[0] == 'l') {
   	  	printf(" -> %s", a[i].link);
   	  }
   	  printf("\n");
   }
   // read directory entries
   // struct dirent *entry; // UNCOMMENT this line
   // ... TODO ...

   // finish up
   closedir(df); // UNCOMMENT this line
   return EXIT_SUCCESS;
}

// convert octal mode to -rwxrwxrwx string
char *rwxmode(mode_t mode, char *str)
{
   int permit = mode & 511;
   int cal_type = mode & S_IFMT;
   if (cal_type == S_IFDIR) {
   	   str[0] = 'd';
   } else if (cal_type == S_IFREG) {
   	   str[0] = '-';
   } else if (cal_type == S_IFLNK) {
   	   str[0] = 'l';
   } else {
       str[0] = '?';
   }
   int i;
   for (i = 1; i <= 9; i++) {
      // printf("%d\n", (((1 << (9 - i)) & permit)) >> (9 - i));
   	   str[i] = b[i % 3][((1 << (9 - i)) & permit) >> (9 - i)];
   }
   str[10] = '\0';
   return str;
   // ... TODO ...
}

// convert user id to user name
char *username(uid_t uid, char *name)
{
   struct passwd *uinfo = getpwuid(uid);
   if (uinfo == NULL)
      snprintf(name, MAXNAME, "%d?", (int)uid);
   else
      snprintf(name, MAXNAME, "%s", uinfo->pw_name);
   return name;
}

// convert group id to group name
char *groupname(gid_t gid, char *name)
{
   struct group *ginfo = getgrgid(gid);
   if (ginfo == NULL)
      snprintf(name, MAXNAME, "%d?", (int)gid);
   else
      snprintf(name, MAXNAME, "%s", ginfo->gr_name);
   return name;
}
