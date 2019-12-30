.data
    x: .asciiz  "The first number\n"
    y: .asciiz  "The second number\n"
    z: .asciiz  "The numbers are equal\n"
    z2: .asciiz "The numbers are different\n"
.text
    main:
        li $v0, 4
        la $a0, x
        syscall
        li $v0, 5
        syscall
        move $a1, $v0
        li $v0, 4
        la $a0, y
        syscall
        li $v0, 5
        syscall
        move $a2, $v0
        
        beq $a1, $a2, numberEqual
        bne $a1, $a2, numberDifferent
        li $v0, 10
        syscall
        
   numberEqual:
         li $v0, 4
         la $a0, z
         syscall
         jr $ra       
         
   numberDifferent:
         li $v0, 4
         la $a0, z2
         syscall
         jr $ra
