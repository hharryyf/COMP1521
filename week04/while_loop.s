.data

.text
   main:
       
       addi $t0, $zero, 0
       addi $t1, $zero, 0
       while:
            bgt $t0, 10, exit
            add $t1, $t1, $t0
            addi $t0, $t0, 1
            
            j while
       exit:
       
           li $v0, 1
           move $a0, $t1
           syscall
           
           li $v0, 10
           syscall
