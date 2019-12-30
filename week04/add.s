	  .data
x:	  .space 4
y:    .space 4
ask1: .asciiz "first\n" 
ask2: .asciiz "the second number\n"
eol:  .byte 't'
a:    .word  23
z:    .word 3
	  .text
main:
      
      li $v0, 4
      la $a0, ask1
      syscall
      
      li $v0, 5
      syscall
      move $a1, $v0
      li $v0, 4
      la $a0, ask2
      syscall
      li $v0, 5
      syscall
      move $a2, $v0
      jal addNumbers
      
      li  $v0, 1
      move $a0, $v1
      syscall
      
      li $v0, 10
      syscall
	  
	  addNumbers:
	      add $v1, $a1, $a2
	  	  jr $ra      
