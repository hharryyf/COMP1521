.data

myarray: .space  1000

.text

main:

li $t0, 0
li $t1, 4
li $t2, 5
li $t3, 6
sw $t1, myarray($t0)
addi $t0, $t0, 4
sw $t2, myarray($t0)
addi $t0, $t0, 4
sw $t3, myarray($t0)
addi $t0, $t0, 4
move $t0, $zero
li $t4, 0
li $t5, 8
li $t6, 0
while: 
   bgt $t0, $t5 exit
   lw $t4, myarray($t0) 
   add $t6, $t6, $t4
   addi $t0, $t0, 4
j while

exit:
li $v0, 1
move $a0, $t6
syscall

li $v0, 10
syscall
