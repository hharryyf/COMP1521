# COMP1521 18s2 Week 04 Lab
# Compute factorials, iterative function


### Global data

   .data
msg1:
   .asciiz "n  = "
msg2:
   .asciiz "n! = "
eol:
   .asciiz "\n"

### main() function
   .text
   .globl main
main:
   #  set up stack frame
   sw    $fp, -4($sp)       # push $fp onto stack
   la    $fp, -4($sp)       # set up $fp for this function
   sw    $ra, -4($fp)       # save return address
   sw    $s0, -8($fp)       # save $s0 to use as ... int n;
   addi  $sp, $sp, -12      # reset $sp to last pushed item

   #  code for main()
   li    $s0, 0             # n = 0;
   
   la    $a0, msg1
   li    $v0, 4
   syscall                  # printf("n  = ");

   li    $v0, 5
   syscall                  # scanf("%d", into $v0)
   
   jal fac
   addi $t0, $v0, 0
   
# ... TODO: add your code here for  tmp = fac(n); ...
# ... place the parameter in $a0 and get the result from $v0 ...
   
   la    $a0, msg2
   li    $v0, 4
   syscall                  # printf("n! = ");

   move  $a0, $t0           # assume $t0 holds n!
   li    $v0, 1
   syscall                  # printf("%d\n",tmp);

   la    $a0, eol
   li    $v0, 4
   syscall                  # printf("\n");

   # clean up stack frame
   lw    $s0, -8($fp)       # restore $s0 value
   lw    $ra, -4($fp)       # restore $ra for return
   la    $sp, 4($fp)        # restore $sp (remove stack frame)
   lw    $fp, ($fp)          # restore $fp (remove stack frame)

   li    $v0, 0
   jr    $ra                # return 0

# fac() function
fac:
   # setup stack frame
   sw    $fp, -4($sp)       # push $fp onto stack
   la    $fp, -4($sp)       # set up $fp for this function
   sw    $ra, -4($fp)       # save return address
   sw    $s0, -8($fp)       # save $s0 to use as ... int i;
   sw    $s1, -12($fp)      # save $s1 to use as ... int prod;
   addi  $sp, $sp, -16      # reset $sp to last pushed item

   # code for fac()
   li $s0, 1
   li $s1, 1
   
   move $t3, $v0
   
   for:
      bgt $s0, $t3, exit 
      mul $s1, $s1, $s0
      addi $s0, $s0, 1
# ... TODO: place your code for the body of fac() here ...
# ... use the value of n in $a0, place n! in $v0 ...
   j for
   exit:
   addi $v0, $s1, 0
   # clean up stack frame
   lw    $s1, -12($fp)      # restore $s1 value
   lw    $s0, -8($fp)       # restore $s0 value
   lw    $ra, -4($fp)       # restore $ra for return
   la    $sp, 4($fp)        # restore $sp (remove stack frame)
   lw    $fp, ($fp)         # restore $fp (remove stack frame)

   jr    $ra                # return prod;
