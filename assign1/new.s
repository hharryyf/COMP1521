.data
n:
	.byte 'n', 'e'
c:
	.byte 'z'
a:   .byte 'a'
.text
main:


lb  $t2, c
li  $t3, 'a'
sub $t4, $t2, $t3
move $a0, $t4
li $v0, 1
syscall

li $v0, 10
syscall
