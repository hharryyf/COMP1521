// COMP1521 18s2 Week 10 Lab
// dns.c ... simple DNS lookup client

#include <stdio.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>

int main(int argc, char **argv)
{
   struct in_addr ip;   // see "man 3 inet_aton"
   struct hostent *hp;  // see "man 3 gethostbyname"
   int i;
   //char IP[BUFSIZ];
   if (argc < 2) {
      printf("Usage: %s HostName|IPaddr\n", argv[0]);
      return 1;
   }
/*
   if (argv[1] looks like an IP address) {
   use gethostbyaddr() to determine its hostname
   if (no match)
      print error message
   else
      print "IP -> hostname"
	}
	else {  // might be a hostname
   use gethostbyname() to determine its IP address
   if (no match)
      print error message
   else
      print "hostname -> IP"
	}
*/
   struct in_addr **addr_list;
   if (!inet_aton(argv[1], &ip)) {
   		hp = gethostbyname(argv[1]);
   		if (hp == NULL) {
   			printf("Can't resolve %s\n", argv[1]);
   		} else {
   			addr_list = (struct in_addr **) hp->h_addr_list; // why this line of code is necessary?
   			for (i = 0 ; addr_list[i] != NULL; i++) {
   				// printf("%s\n", hp->h_addr_list[i]);
   				//strcpy(IP, inet_ntoa(*addr_list[i]));
   				printf("%s -> %s\n", hp->h_name, inet_ntoa(*addr_list[i]));
   				//break;
   			}
   			//printf("%s -> %s\n", hp->h_name, IP);
   		}
   } else {
   		hp = gethostbyaddr(&ip, sizeof(struct hostent), AF_INET);
   		if (hp == NULL) {
   			 printf("No name associated with %s\n", argv[1]);
   		} else {
   			printf("%s -> %s\n", inet_ntoa(ip), hp->h_name);
   		}
   }
   
   if (hp != NULL) {
   		// addr_list = (struct in_addr **) hp->h_aliases;
   		for (i = 0 ; hp->h_aliases[i] != NULL; i++) {
   			// strcpy(IP, inet_ntoa(*addr_list[i]));
   			// hp2 = gethostbyname(IP);
   			// if (hp2 == NULL) {
   				// continue;
        	// }
   			printf("%s\n", hp->h_aliases[i]);
   		}
   }
   return 0;
}
