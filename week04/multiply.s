.data
 x: .word 123333
 y: .word 1241444
.text
main:
  addi $t0, $zero, 32767
  addi $t1, $zero, 32767
  mult $t0, $t1
  mflo $t2
  mfhi $t3
  li $v0, 1
  move $a0, $t3
  syscall
  li $v0, 1
  move $a0, $t2
  syscall
  
  li $v0, 10
  syscall
