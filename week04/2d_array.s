	.data
array: .word 1, 2, 3, 4
       .word 5, 6, 7, 8
       .word 9, 10, 11, 12
       .word 13, 14, 15, 16
size: .word 4
x: .byte '\n'
	.text
main:

	la $a1, array
	move $t0, $a1
	
	addi $t1, $t0, 60
	while:
		bgt $t0, $t1, exit
		lw $t2, ($t0)
		li $v0, 1
		move $a0, $t2
		syscall
		li $v0, 4
		la $a0, x
		syscall
		addi $t0, $t0, 4
	j while
	
	exit:
		li $v0, 10
		syscall
	


