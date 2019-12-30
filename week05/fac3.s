# COMP1521 18s2 Week 04 Lab
# Compute factorials, no functions (except main)

### Global data

   .data
msg1:
   .asciiz "n  = "
msg2:
   .asciiz "n! = "
eol:
   .asciiz "\n"
array:
   .word   0:100
### main() function
   .text
   .globl main

main:
   # set up stack frame
   sw    $fp, -4($sp)       # push $fp onto stack
   la    $fp, -4($sp)       # set up $fp for this function
   sw    $ra, -4($fp)       # save return address
   sw    $s0, -8($fp)       # save $s0 to use as ... int n;
   sw    $s1, -12($fp)      # save $s1 to use as ... int i;
   sw    $s2, -16($fp)      # save $s2 to use as ... int fac;
   sw    $s3, -20($fp)
   addi  $sp, $sp, -24      # move $sp to top of stack

   # code for main()
   li    $s0, 0             # n = 0;
   
   la    $a0, msg1
   li    $v0, 4
   syscall                  # printf("n  = ");

   li    $v0, 5
   syscall                  # scanf("%d", into $v0)

   move $s0,$v0
   la $t0, array
   li $s2, 1
   sw $s2, ($t0)
   li $t1, 1
   li $t3, 396
   li $s1, 10   #s1 is 10 the MOD
   while_1:
       bgt $t1, $s0, endwhile
       li $t2, 0
       li $t5, 0   # t5 is like carry
       while_2:
       	  bgt $t2, $t3, end_while_2
       	  la $t4, array
       	  add $t4, $t4, $t2
       	  #t4 is now the address of array[i]
       	  # data = ((a[i] * t1) + t5) /10
       	  # carry = ((a[i] * t1) + t5) % 10
       	  # array[i] = data
       	  lw $t7, ($t4) #t7 is now a[i]
       	  mul $t6, $t7, $t1
       	  add $t6, $t6, $t5
       	  div $t5, $t6, $s1 #t8 is the data
       	  rem $t8, $t6, $s1
       	  sw  $t8, ($t4)
       	  addi $t2, $t2, 4
       j while_2		
       end_while_2:
       addi $t1, $t1, 1
       j while_1
   
   endwhile:
   la    $a0, msg2
   li    $v0, 4
   syscall                  # printf("n! = ");
   blt $s1, 1 exit
   la $t0, array
   li $t3, 396
   add $t3, $t3, $t0
   li $t4, 1
   while_3:
   	blt $t3, $t0, exit
   	lw $s1, ($t3)
   	beq $t4, $zero, print
   	beq $s1, $zero, continue
   	li $t4, 0
   	print:
   	move  $a0, $s1          # assume $s2 holds n!
   	li    $v0, 1
   	syscall 
   	continue:
   	addi $t3,$t3, -4 
   j while_3                 # printf("%d",fac);
   exit:
   
   la    $a0, eol
   li    $v0, 4
   syscall                  # printf("\n");

   # clean up stack frame
   lw    $s3, -20($fp)
   lw    $s2, -16($fp)      # restore $s2 value
   lw    $s1, -12($fp)      # restore $s1 value
   lw    $s0, -8($fp)       # restore $s0 value
   lw    $ra, -4($fp)       # restore $ra for return
   la    $sp, 4($fp)        # restore $sp (remove stack frame)
   lw    $fp, ($fp)         # restore $fp (remove stack frame)

   li    $v0, 0
   jr    $ra                # return 0

