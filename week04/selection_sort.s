.data
array: .space 1024
N: .space 4
.text

main:
	sw $fp, -4($sp)
	la $fp, -4($sp)
	sw $ra, -4($fp)
	sw $s0, -8($fp)
	sw $s1, -12($fp)
	addi $sp, $sp, -16
								# scanf("%d", &n)
	li $v0, 5
	syscall
	sw $v0, N 
	
	li $s0, 0
	lw $t0, N
	la $s1, array
	li $t2, 4
	while_1: 					# while (i < N)
		move $a0, $s0
		bge $s0, $t0, exit_1
		mul $t3, $t2, $s0		# &array[i] = array + 4*i
		addu $t4, $s1, $t3
		li   $v0, 5
		syscall
		sw  $v0, ($t4)          # array[i] = value
		addi $s0, $s0, 1 		# i++
	j while_1
	
	exit_1:
	
    jal sort
	
	li $s0, 0
	lw $t0, N
	la $s1, array
	li $t2, 4
	while_2: 					# while (i < N)
		bge $s0, $t0, exit_2
		mul $t3, $t2, $s0		# &array[i] = array + 4*i
		addu $t4, $s1, $t3
		li   $v0, 1
		lw  $a0, ($t4)          # array[i] = value
		syscall
		li $a0, ' '
		li $v0, 11
		syscall
		addi $s0, $s0, 1 		# i++
	j while_2
	exit_2:
	
	li $a0, '\n'
	li $v0, 11
	syscall
	
	lw $s1, -12($fp)
	lw $s0, -8($fp)
	lw $ra, -4($fp)
	la $sp, 4($fp)
	lw $fp, ($fp)
	li $v0, 0
	jr $ra
	
sort:
	sw $fp, -4($sp)
	la $fp, -4($sp)
	sw $ra, -4($fp)
	sw $s0, -8($fp)
	sw $s1, -12($fp)
	sw $s2, -16($fp)
	sw $s3, -20($fp)
	sw $s4, -24($fp)
	sw $s5, -28($fp)
	sw $s6, -32($fp)
	sw $s7, -36($fp)
	addi $sp, $sp, -40
	# for (i = 0 ; i < n; i++) {
	#	min = a[i];
	#	index = i;
	#	for (j = i; j < n; j++) {
	#		if (a[j] < min) {
	#			index = j;
	#			min = a[j]
	#		}
	#	}
	#	tmp = a[index];
	#	a[index] = a[i];
	#	a[i] = tmp;
	# }
	
	la $s0, array
	li $s1, 0             # i = 0
	li $s2, 4
	lw $t9, N
	while_3:
		bge $s1, $t9, exit_3  # i < N
		mul $s3, $s2, $s1     # 4*i
		addu $s4, $s0, $s3    # &array[i] = array + 4 * i
		lw $s5, ($s4)         # min = array[i]
		move $s6, $s1         # j = i
		move $t6, $s1         # index = i
		while_4:
			bge $s6, $t9, exit_4    # j < N
			mul $s3, $s2, $s6     # 4*j
			addu $s7, $s0, $s3    # &array[j] = array + 4 * j
			lw  $t3, ($s7)
			bge $t3, $s5, continue  # a[j] >= min continue
			move $t6, $s6         # index = j
			move $s5, $t3         # min = a[j]
			continue:
			addi $s6, $s6, 1  # j++
		j while_4
		exit_4:
		# swap(array[$t6], array[$s1])
		mul $s3, $s2, $s1     # 4*i
		addu $t1, $s0, $s3    # &array[i] = array + 4 * i
		lw $t2, ($t1)         # min = array[i]
		mul $s3, $s2, $t6     # 4*i
		addu $t0, $s0, $s3    # &array[i] = array + 4 * i
		lw $t3, ($t0)         # min = array[i]
		sw $t2, ($t0)
		sw $t3, ($t1)
		addi $s1, $s1, 1  # i++
	j while_3
	
	exit_3:
	
	lw $s7, -36($fp)
	lw $s6, -32($fp)
	lw $s5, -28($fp)
	lw $s4, -24($fp)
	lw $s3,	-20($fp)
	lw $s2, -16($fp)
	lw $s1, -12($fp)
	lw $s0, -8($fp)
	lw $ra, -4($fp)
	la $sp, 4($fp)
	lw $fp, ($fp)
	li $v0, 0
	jr $ra
