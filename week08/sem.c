



sem_t *exclusion;
if ((exclusion = sem_open("my_sem", O_CREAT, 0644, 1) == SEM_FAILED) {
	perror("sem_open failed");
	exit(1);
}

if ((pid = fork()) != 0) {
	for (i = 0 ; i < 5; i++) {
		sem_wait(exclusion);   // wait the signal
		for (j = 0 ; j < 26; j++) {
			putchar('a' + j);
		}
		printf("\n");
		sem_post(exclusion);  // like signal
	} 
} else {
	for (i = 0 ; i < 5; i++) {
		sem_wait(exclusion);   // wait the signal
		for (j = 0 ; j < 26; j++) {
			putchar('A' + j);
		}
		printf("\n");
		sem_post(exclusion);  // like signal
	}
}

