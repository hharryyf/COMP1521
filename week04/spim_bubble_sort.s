	.data
newline: .byte '\n'
array: .word 0:200
x: .space 4
	.text
main:
	li $v0, 5
	li $s0, 4
	syscall
	move $t0, $v0
	li $t1, 0
	la $t2, array
	while:
	    bge $t1, $t0, exit
	    li $v0, 5
	    syscall
	    sw $v0, ($t2) 
	    addi $t1, $t1, 1
		addi $t2, $t2, 4
	j while
	exit:
	la $t2, array
	li $t1, 0
	li $t3, 0
	#for (i = 0  ; i < n; i++) {
	#	for (j = i ; j < n; j++) {
	#		if (*(a+i) > *(a+j)) {
	#			tmp = *(a+i);
	#			*(a+i) = *(a+j);
	#			*(a+j) = tmp;
	#		}
	#	}
	#}
	outerloop:
		bge $t3, $t0, exit3
		move $t4, $t3
		addi $t4, $t4, 1
		move $t5, $t3
		mul $t5, $t5, $s0
		add $t5, $t5, $t2
		inerloop:
			bge $t4, $t0, exit2
			move $t6, $t4
			mul $t6, $t6, $s0
			add $t6, $t6, $t2
			lw $s1 ($t6)
			lw $s2 ($t5)
			bge $s1, $s2, continue
			lw $t7, ($t5)
			lw $t8,	($t6)
			sw $t8, ($t5) 
			sw $t7, ($t6)
			j continue
			continue:
			addi $t4, $t4, 1
			j inerloop
					
	exit2:
	addi $t3, $t3, 1
	j outerloop
	
	exit3:
	la $t2, array
	li $t1, 0
	li $t3, 0
	for:
		bge $t1, $t0, exit4
	    li $v0, 1
	    lw $t3, ($t2)
	    move $a0, $t3
	    syscall
	    li $v0, 4
	    la $a0, newline
	    syscall
	    addi $t1, $t1, 1
		addi $t2, $t2, 4 
	j for
	exit4:
	li $v0,10
	syscall
	
	
	    
	
