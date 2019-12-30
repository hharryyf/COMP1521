# COMP1521 Practice Prac Exam #1
# main program + show function

   .data
msg1:
   .asciiz "The matrix\n"
msg2:
   .asciiz "is an identity matrix\n"
msg3:
   .asciiz "is not an identity matrix\n"
   .align  2

   .text
   .globl main
main:
   addi $sp, $sp, -4
   sw   $fp, ($sp)
   la   $fp, ($sp)
   addi $sp, $sp, -4
   sw   $ra, ($sp)
   addi $sp, $sp, -4
   sw   $s1, ($sp)

   la   $a0, m
   lw   $a1, N
   jal  is_ident      # s1 = is_ident(m,N)
   move $s1, $v0

   la   $a0, msg1
   li   $v0, 4
   syscall           # printf("The matrix\n")
   la   $a0, m
   lw   $a1, N
   jal  showMatrix   # showMatrix(m, N)

main_if:             # if (s1)
   beqz $s1, main_else
   la   $a0, msg2
   li   $v0, 4
   syscall           # printf("is an identity matrix\n")
   j    end_main_if

main_else:           # else
   la   $a0, msg3
   li   $v0, 4
   syscall           # printf("is not an identity matrix\n")

end_main_if:
   lw   $s1, ($sp)
   addi $sp, $sp, 4
   lw   $ra, ($sp)
   addi $sp, $sp, 4
   lw   $fp, ($sp)
   addi $sp, $sp, 4
   j    $ra

# end main()

# void showMatrix(m, N)
# params: m=$a0, N=$a1
# locals: m=$s0, N=$s1, row=$s2, col=$s3
showMatrix:
   addi $sp, $sp, -4
   sw   $fp, ($sp)
   la   $fp, ($sp)
   addi $sp, $sp, -4
   sw   $ra, ($sp)
   addi $sp, $sp, -4
   sw   $s0, ($sp)
   addi $sp, $sp, -4
   sw   $s1, ($sp)
   addi $sp, $sp, -4
   sw   $s2, ($sp)
   addi $sp, $sp, -4
   sw   $s3, ($sp)

   move $s0, $a0
   move $s1, $a1
   li   $s2, 0
show_matrix_loop1:
   bge  $s2, $s1, end_show_matrix_loop1

   li   $s3, 0
show_matrix_loop2:
   bge  $s3, $s1, end_show_matrix_loop2

   li   $a0, ' '          # putchar(' ')
   li   $v0, 11
   syscall

   move $t0, $s2
   mul  $t0, $t0, $s1
   add  $t0, $t0, $s3
   li   $t1, 4
   mul  $t0, $t0, $t1
   add  $t0, $t0, $s0
   lw   $a0, ($t0)
   li   $v0, 1            # printf("%d",m[row][col])
   syscall

   addi $s3, $s3, 1       # col++
   j    show_matrix_loop2

end_show_matrix_loop2:
   li   $a0, '\n'         # putchar('\n')
   li   $v0, 11
   syscall

   addi $s2, $s2, 1       # row++
   j    show_matrix_loop1

end_show_matrix_loop1:

   lw   $s3, ($sp)
   addi $sp, $sp, 4
   lw   $s2, ($sp)
   addi $sp, $sp, 4
   lw   $s1, ($sp)
   addi $sp, $sp, 4
   lw   $s0, ($sp)
   addi $sp, $sp, 4
   lw   $ra, ($sp)
   addi $sp, $sp, 4
   lw   $fp, ($sp)
   addi $sp, $sp, 4
   j    $ra

   .text
   .globl is_ident

# params: m=$a0, n=$a1
is_ident:
# prologue
   addi $sp, $sp, -4
   sw   $fp, ($sp)
   la   $fp, ($sp)
   addi $sp, $sp, -4
   sw   $ra, ($sp)
   addi $sp, $sp, -4
   sw   $s0, ($sp)
   addi $sp, $sp, -4
   sw   $s1, ($sp)
   addi $sp, $sp, -4
   sw   $s2, ($sp)
   addi $sp, $sp, -4
   sw   $s3, ($sp)
   #s0 has the address of a[0][0]
   move $s0, $a0
   move $s1, $a1
   # a[i][j] would be s0+
   li $t0, 0
   li $s2, 4
   li $t5, 1
   while_1:
   	  bge $t0, $s1, exit_1
   	  li $t1, 0
   	  while_2:
   	  	  bge $t1, $s1, end_2
   	  	  mul $t3, $t0, $s1
   	  	  add $t3, $t3, $t1
   	  	  mul $t3, $t3, $s2
   	  	  move $s0, $a0
   	  	  add $s0, $t3, $s0
   	  	  beq $t0, $t1 test_1
   	  	  bne $t0, $t1 test_2
   	  	  test_1:
   	  	     lw $t4, ($s0)
   	  	     bne $t4, $t5, exit_0
   	  	  j continue
   	  	  test_2:
   	  	  	 lw $t4, ($s0)
   	  	     bne $t4, $zero, exit_0
   	  	  continue:
   	  	  addi $t1, $t1, 1
   	  j while_2
   end_2:
   addi $t0, $t0, 1
   j while_1
   
   # if you need to save more than four $s? registers
   # add extra code here to save them on the stack

# ... your code for the body of is_ident(m,N) goes here ...

# epilogue
   # if you saved more than four $s? registers
   # add extra code here to restore them
   exit_1:
   li $v0, 1
   j exit
   exit_0:
   li $v0, 0
   exit:
   lw   $s3, ($sp)
   addi $sp, $sp, 4
   lw   $s2, ($sp)
   addi $sp, $sp, 4
   lw   $s1, ($sp)
   addi $sp, $sp, 4
   lw   $s0, ($sp)
   addi $sp, $sp, 4
   lw   $ra, ($sp)
   addi $sp, $sp, 4
   lw   $fp, ($sp)
   addi $sp, $sp, 4
   j    $ra

# COMP1521 18s1 Exam Q1
# Matrix data

   .data
N:
   .word   9
m:
   .word   1, 0, 0, 0, 0, 0, 0, 0, 0
   .word   0, 1, 0, 0, 0, 0, 0, 0, 0
   .word   0, 0, 1, 0, 0, 0, 0, 0, 0
   .word   0, 0, 0, 1, 0, 0, 0, 0, 0
   .word   0, 0, 0, 0, 1, 0, 0, 0, 0
   .word   0, 0, 0, 0, 0, 1, 0, 0, 0
   .word   0, 0, 0, 0, 0, 0, 1, 0, 0
   .word   0, 0, 0, 0, 0, 0, 0, 1, 0
   .word   0, 0, 0, 0, 0, 0, 0, 0, 1

   .align  2

