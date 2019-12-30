             ############################################################ -*- asm -*-
# COMP1521 18s2 -- Assignment 1 -- Scrolling Text!
# Scroll letters from a message in argv[1]
#
# Base code by Jashank Jeremy
# Tweaked by John Shepherd
# $Revision: 1.5 $
#
# Edit me with 8-column tabs!

# Requires:
#  - `all_chars', defined in chars.s

# Provides:
	.globl	main # :: int, [char *], [char *] -> int
	.globl	setUpDisplay # :: int, int -> void
	.globl	showDisplay # :: void -> void
	.globl	delay # :: int -> vovid
	.globl	isUpper # :: char -> int
	.globl	isLower # :: char -> int

	.globl	CHRSIZE
	.globl	NROWS
	.globl	NDCOLS
	.globl	MAXCHARS
	.globl	NSCOLS
	.globl	CLEAR


########################################################################
	.data

	# /!\ NOTE /!\
	# In C, the values of the symbols `CHRSIZE', `NROWS', `NDCOLS',
	# `NSCOLS', `MAXCHARS', and `CLEAR' would be substituted during
	# preprocessing.  SPIM does not have preprocessing facilities,
	# so instead we provide these values in the `.data' segment.

	# # of rows and columns in each big char
CHRSIZE:	.word	9
	# number of rows in all matrices
NROWS:		.word	9
	# number of columns in display matrix
NDCOLS:		.word	80
	# max length of input string
MAXCHARS:	.word	100
	# number of columns in bigString matrix
	# max length of buffer to hold big version
	# the +1 allows for one blank column between letters
NSCOLS:		.word	9000	# (NROWS * MAXCHARS * (CHRSIZE + 1))
        # ANSI escape sequence for 'clear-screen'
CLEAR:	.asciiz "\033[H\033[2J"
# CLEAR:	.asciiz "__showpage__\n" # for debugging

main__0:	.asciiz	"Usage: ./scroll String\n"
main__1:	.asciiz	"Only letters and spaces are allowed in the string!\n"
main__2:	.asciiz "String mush be < "
main__3:	.asciiz " chars\n"
main__4:	.asciiz "Please enter a string with at least one character!\n"

	.align	4
theString:	.space	101	# MAXCHARS + 1
	.align	4
display:	.space	720	# NROWS * NDCOLS
	.align	4
bigString:	.space	81000	# NROWS * NSCOLS
new_line: .byte '\n'
aspace:  .byte ' '
biga:    .byte 'A'
smalla:  .byte 'a'
hello:   .asciiz "ABC ABC Zacke is"   # this is a testing string
########################################################################
# .TEXT <main>
	.text
main:

# Frame:	$fp, $ra, ...
# Uses:		$a0, $a1, $a2, $t0, $t1, $t2, $s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7
#           $t8, $t9
# Clobbers:	$t9, $t5, $t6, $t8, $t7,$s2, $s3, $s4, $s5, $s6
# need to be careful $a1, $a2 should never be used in the main(exp. jal)
# Locals:
#	- `theLength' in $s0
#	- `bigLength' in $s1, $a1
#	- `ch' in $s2
#	- `str' in $t2
#	- `i' in $s3
#	- `j' in $s4
#	- `row' in $s5
#	- `col' in $s6
#	- `iterations' in $t8
#	- `startingCol' in $t9, $a2
#    - NROWS in  $t3
#    - NDCOLS in $t4
#    - CHARSIZE in $t5
#    - &display[0][0] in  $s7
# Structure:
#	main
#	-> [prologue]
#	-> main_argc_gt_two
#	-> main_PTRs_init
#	  -> main_PTRs_cond
#	    -> main_ch_notspace
#	    -> main_ch_isLower
#	    -> main_ch_isSpace
#	  -> main_PTRs_step
#	-> main_PTRs_f
#	[theLength cond]
#	  | main_theLength_ge_MAXCHARS
#	  | main_theLength_lt_MAXCHARS
#	  | main_theLength_lt_1
#	  | main_theLength_ge_1
#	... -> main_for_1
#        -> main_for_2
#   ... -> exit_for_1
#   ... -> main_for_3
#	 	[theCharacter cond]
#    	[actually ' ']
# 	       ->main_for_4
#           ->main_for_5
#  	    [else_condition]
#         [higher_lower_case_test]
#		  start_loop
#            ->main_for_6
#              ->main_for_7
#                 ->main_for_8
#   ...->last_loop
#        [setUpdisplay]
#        [showDisplay]
#   ->exit_last_loop
#	-> [epilogue]

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	la	$fp, -4($sp)
	sw	$ra, -4($fp)  # note: switch to $fp-relative
	sw	$s0, -8($fp)
	sw	$s1, -12($fp)
	sw	$s2, -16($fp)
	sw  $s3, -20($fp)
	sw  $s4, -24($fp)
	sw  $s5, -28($fp)
	sw  $s6, -32($fp)
	sw  $s7, -36($fp)
	addi	$sp, $sp, -40

	# if (argc < 2)
#	li  $a0, 2  # could comment
	li	$t0, 2
	bge	$a0, $t0, main_argc_gt_two
	nop	# in delay slot
	# printf(...)
	la	$a0, main__0
	li	$v0, 4 # PRINT_STRING_SYSCALL
	syscall
	# return 1  =>  load $v0, jump to epilogue
	li	$v0, 1
	j	main__post
	nop	# in delay slot
main_argc_gt_two:

	move	$s0, $zero
main_PTRs_init:
	# s = argv[1]
	lw	$t2, 4($a1)
#	la  $t2, hello
main_PTRs_cond:
	# optimisation: `ch = *s' now
	# (ch = )*s
	lb	$s2, ($t2)
	# *s != '\0'  =>  ch != 0
	beqz	$s2, main_PTRs_f
	nop	# in delay slot

	# if (!isUpper(ch))
main_ch_upper:
	move	$a0, $s2
	jal	isUpper
	nop	# in delay slot
	beqz	$v0, main_ch_lower
	nop	# in delay slot
	j	main_ch_ok
	nop	# in delay slot
	# if (!isLower(ch))
main_ch_lower:
	move	$a0, $s2
	jal	isLower
	nop	# in delay slot
	beqz	$v0, main_ch_space
	nop	# in delay slot
	j	main_ch_ok
	nop	# in delay slot
	# if (ch != ' ')
main_ch_space:
	li	$t0, ' '
	bne	$s2, $t0, main_ch_fail
	nop	# in delay slot
	j	main_ch_ok
	nop	# in delay slot

main_ch_fail:
	# printf(...)
	la	$a0, main__1
	li	$v0, 4 # PRINT_STRING_SYSCALL
	syscall
	# exit(1)  =>  return 1  =>  load $v0, jump to epilogue
	li	$v0, 1
	j	main__post
	nop	# in delay slot

main_ch_ok:
	# if (theLength >= MAXCHARS)
	la	$t0, MAXCHARS
	lw	$t0, ($t0)
	# break  =>  jump out of for(*s...)
	bge	$s0, $t0, main_PTRs_f

	# theString[theLength]
	la	$t0, theString
	addu	$t0, $t0, $s0	# ADDU because address
	# theString[theLength] = ch
	sb	$s2, ($t0)

	# theLength++
	addi	$s0, $s0, 1

main_PTRs_step:
	# s++  =>  s = s + 1
	addiu	$t2, $t2, 1	# ADDIU because address
	j	main_PTRs_cond
	nop
main_PTRs_f:

	# theString[theLength] = ...
	la	$t0, theString
	addu	$t0, $t0, $s0	# ADDU because address
	# theString[theLength] = '\0'
	sb	$zero, ($t0)

	# CHRSIZE + 1
	la	$t0, CHRSIZE
	lw	$t0, ($t0)
	addi	$t0, $t0, 1
	# bigLength = theLength * (CHRSIZE + 1)
	mul	$s1, $t0, $s0

	# if (theLength >= MAXCHARS)
	la	$t0, MAXCHARS
	lw	$t0, ($t0)
	blt	$s0, $t0, main_theLength_lt_MAXCHARS
	nop	# in delay slot
main_theLength_ge_MAXCHARS:
	# printf(..., ..., ...)
	la	$a0, main__2
	li	$v0, 4 # PRINT_STRING_SYSCALL
	syscall
	move	$a0, $t0
	li	$v0, 1 # PRINT_INT_SYSCALL
	syscall
	la	$a0, main__3
	li	$v0, 4 # PRINT_STRING_SYSCALL
	syscall
	# return 1  =>  load $v0, jump to epilogue
	li	$v0, 1
	j	main__post
	nop	# in delay slot
main_theLength_lt_MAXCHARS:

	# if (theLength < 1)
	li	$t0, 1
	bge	$s0, $t0, main_theLength_ge_1
	nop	# in delay slot
main_theLength_lt_1:
	# printf(...)
	la	$a0, main__4
	li	$v0, 4 # PRINT_STRING_SYSCALL
	syscall
	# exit(1)  =>  return 1  =>  load $v0, jump to epilogue
	li	$v0, 1
	j	main__post
	nop	# in delay slot
main_theLength_ge_1:

	li $s3, 0
	# now $s0 has theLength and $s1 has bigLength
	lw $t3, NROWS
	lw $t4, NDCOLS
	la $s7, display    #s7 = &display[0][0]
	lb $t8, aspace
	main_for_1:
		bge $s3, $t3, exit_for_1
		li  $s4, 0
		main_for_2:
		bge $s4, $t4, continue_for_1
		# &display[s1][s2] = s1*t2 + s2 + &display[0][0]
		mul $t5, $s3, $t4
		add $t5, $t5, $s4
		addu $t5, $t5, $s7       # addu because of address
		sb  $t8, ($t5)           # display[i][j] = ' '
		addi $s4, $s4, 1         # j ++
		j main_for_2
		continue_for_1:
		addi $s3, $s3, 1         # i ++
	j main_for_1
	exit_for_1:
	
	li $s3, 0    # i = 0
	
	main_for_3:
		la $s4, theString    #s4 = &theString[0]
		la $s7, bigString     # let s7 holds &bigString[0][0]
		bge $s3, $s0, exit_create_bigchar  # i < theLength
		addu $t4, $s4, $s3                  # $t4 now holds the address of theString[i]
		lb  $s2, ($t4)                     # ch = theString[i]
		lb  $t8, aspace
		bne $s2, $t8, else_condition       # actually if ch == ' '
		lw  $t5, CHRSIZE                   # $t5 holds CHRSIZE
		li  $s5, 0                    # row = 0
		main_for_4:
			bge	 $s5, $t5, exit_main_for_4  # row < CHRSIZE
			li   $s6, 0                     # col = 0
			main_for_5:
				bge   $s6, $t5, continue_main_for_4  # col < CHRSIZE
				lw    $t9, NSCOLS
				lb    $t8, aspace        # let t8 holds the ' '
				mul   $t6, $t9, $s5         # find the row's row
				mul   $t7, $s3, $t5         # i * CHRSIZE
				add   $t7, $t7, $s3         # i * (CHRSIZE+1)
				add   $t7, $t7, $s6         # col + i * (CHRSIZE+1)
				add   $t6, $t6, $t7         # this is row,col + i * (CHRSIZE+1)
				addu   $t6, $t6, $s7         # find &bigString[row][col + i * (CHRSIZE+1)]
				sb    $t8, ($t6)
				addi  $s6, $s6, 1           # col++
			j main_for_5
		continue_main_for_4:
		addi $s5, $s5, 1              # row++
		j main_for_4
		exit_main_for_4:
		j continue_main_for_3         # we must skip the else part
		# we let $t9 hold which
		else_condition:
		move $a0, $s2                 # a0 = ch
		li   $t8, 1
		jal  isUpper                 # is an upper-case test
		bne  $v0, $t8, lower_test    # not an upper-case
		li   $t3, 'A'
		sub  $t9, $s2, $t3           # which = ch - 'A'
		lower_test:
		jal  isLower
		bne  $v0, $t8, start_loop    # now a low-case fail
		li   $t3, 'a'
		sub  $t9, $s2, $t3           # which = ch - 'a' + 26
		addi $t9, $t9, 26
		start_loop:
		# row in $s5
		# col in $s6
		# CHRSIZE in $t5
		# let s7 holds &bigString[0][0]
		# let s4 holds &all_chars[0][0][0]
		# i is still in $s3
		# which is in $t9
		lw $t5, CHRSIZE
		li $s5, 0       # row = 0
		main_for_6:
			bge $s5, $t5, continue_main_for_3      # row < CHRSIZE
			li  $s6, 0
			main_for_7:
				bge  $s6, $t5, continue_main_for_6 #col < CHRSIZE
				# bigString[row][col + i * (CHRSIZE+1)] = all_chars[which][row][col];
				lw    $t2, NSCOLS
				mul   $t6, $t2, $s5         # find the row's row
				mul   $t7, $s3, $t5         # i * CHRSIZE
				add   $t7, $t7, $s3         # i * (CHRSIZE+1)
				add   $t7, $t7, $s6         # col + i * (CHRSIZE+1)
				add   $t6, $t6, $t7         # this is row,col + i * (CHRSIZE+1)
				addu   $t6, $t6, $s7         # find &bigString[row][col + i * (CHRSIZE+1)]
				#& all_chars[which][row][col] = &0,0,0 + which*CHRSIZE*CHRSIZE + row*CHRSIZE+col
				la    $s4, all_chars
				mul   $t8, $t5, $t5
				mul   $t8, $t8, $t9        # which*CHRSIZE*CHRSIZE
				mul   $t7, $s5, $t5        # which*CHRSIZE*CHRSIZE + row*CHRSIZE
				add   $t8, $t8, $t7
				add   $t8, $t8, $s6        # which*CHRSIZE*CHRSIZE + row*CHRSIZE+col
				addu   $t8, $t8, $s4        # &0,0,0 + which*CHRSIZE*CHRSIZE + row*CHRSIZE+col
				lb    $t7, ($t8)
				sb    $t7, ($t6)           # finish the storage
			addi $s6, $s6, 1
			j main_for_7
		continue_main_for_6:
		addi $s5, $s5, 1
		j main_for_6
	continue_main_for_3:
		lw  $t5, CHRSIZE
		mul $s6, $s3, $t5              # i * CHRSIZE
		add $s6, $s6, $s3              # i * CHRSIZE + i
		add $s6, $s6, $t5              # i * CHRSIZE + i + CHRSIZE
		la  $s7, bigString
		li  $s5, 0
		lw    $t9, NSCOLS
		main_for_8:
			bge  $s5, $t5, exit_for_8
			lb   $t7, aspace
			mul  $t6, $t9, $s5
			add  $t6, $t6, $s6
			addu  $t6, $t6, $s7        # it is &bigString[row][col] 
			sb   $t7, ($t6)
		addi $s5, $s5, 1
		j main_for_8
	exit_for_8:
	addi $s3, $s3, 1                   # i++
	j main_for_3
	exit_create_bigchar:
	lw   $t4, NDCOLS
	add  $t8, $t4, $s1                  # iterations = NDCOLS + bigLength
	addi $s5, $t4, -1                  # starting_col = NDCOLS - 1
	li 	 $s3, 0                     # i = 0
	last_loop:
		bge $s3, $t8, exit_last_loop
		move $a2, $s5             # a2 now stores starting_col
		move $a1, $s1             # a1 now stores bigLength
		jal setUpDisplay          # setUpDisplay(a2, a1)
		jal showDisplay           # showDisplay()
		addi $s5, $s5, -1          # starting_col--
		li   $a0, 1               
		jal  delay                # delay(1)
	addi $s3, $s3, 1
	j last_loop
	exit_last_loop:
	move	$v0, $zero
main__post:
	# tear down stack frame
	lw  $s7, -36($fp)
	lw  $s6, -32($fp)
	lw  $s5, -28($fp)
	lw  $s4, -24($fp)
	lw  $s3, -20($fp)
	lw	$s2, -16($fp)
	lw	$s1, -12($fp)
	lw	$s0, -8($fp)
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra
	nop	# in delay slot

########################################################################
# .TEXT <setUpDisplay>
	.text
setUpDisplay:

# Frame:	$fp, $ra, ...
# Uses:		$a2, $a1, $s0, $s1, $s2, $s3, $s4, $t0, $t1, $t2, $t3
# Clobbers:	$t0, $t1, $t2, $t3, $s3 , $s0, $s1, $s2
# starting = NDCOLS - 1   --$a1
# length =                --$a2
# Locals:
#	- `row' in $s0
#	- `out_col' in $s1
#	- `in_col' in $s2
#	- `first_col' in $s3
#	- -'starting' in $a2
#    - -'length'  in $a1 
#   --  NDCOLS   in  $t0
#   --  &display  in $t1
#   --  &bigString  in $t2
#   --  NSCOLS    in $t7
# Structure:
#	setUpDisplay
#	-> [prologue]
#	-> [first condition test: starting < 0]
#      -> [next_condition]
#	   -> loop_1
#         -> loop_2
#         ->exit_loop_2
#      ->pre_copy
#   -> [copy]
#      -> loop_3
#        ->loop_4
#   -> exit_set_up
#	-> [epilogue]

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	la	$fp, -4($sp)
	sw	$ra, -4($fp)
	sw  $s0, -8($fp)
	sw  $s1, -12($fp)
	sw  $s2, -16($fp)
	sw  $s3, -20($fp)
	sw  $s4, -24($fp)
	addi	$sp, $sp, -28
	lw  $t0,  NDCOLS
	la  $t1,  display
	la  $t2,  bigString
	lb  $t4,  aspace
	lw  $t7,  NSCOLS
	# if (starting < 0)
	bge $a2, $zero, next_condition
		li  $s1, 0  # out_col = 0
		sub $s3, $zero, $a2       # first_col = -starting
		j copy
	next_condition:
		li  $s1, 0  # out_col = 0
		loop_1:
			bge $s1, $a2, pre_copy
			li  $s0, 0    #row = 0
			lw  $s4, NROWS
			loop_2:
		    	bge $s0, $s4, exit_loop_2
		    	# &array[$s0][$s1] = &array[0][0] + $s0 * $t0 + $s1
		    	mul $t3, $s0, $t0
		    	add $t3, $t3, $s1
		    	addu $t3, $t3, $t1
		    	sb  $t4, ($t3)
				addi $s0, $s0,1
			j loop_2
		exit_loop_2:
		addi $s1, $s1, 1
		j loop_1	
	
	pre_copy:
		li $s3, 0   #first_col = 0
	copy:
		move $s2, $s3   # in_col = first_col
		loop_3:
			bge  $s2, $a1, exit_set_up  # in_col < length
			bge  $s1, $t0, exit_set_up  # if (out_col >= NDCOLS) break;
			li   $s0, 0
			lw  $s4, NROWS
			loop_4:
				bge  $s0, $s4, exit_loop_4  # row < NROWS
				# display[row][out_col] = bigString[row][in_col]  <=> 
				# display[$s0][$s1] = bigString[$s0][$s2]  <=>
				mul  $t5, $s0, $t7
				add  $t5, $t5, $s2
				addu  $t5, $t5, $t2
				lb   $t6, ($t5)
				mul  $t5, $s0, $t0
				add  $t5, $t5, $s1
				addu  $t5, $t5, $t1         # addu because of address
				sb   $t6, ($t5)
				addi $s0, $s0, 1            # row++
			j loop_4
			exit_loop_4:
			addi $s1, $s1, 1			# out_col++
			addi $s2, $s2, 1            # in_col++
		j loop_3	

	
	exit_set_up:
	lw  $s4, -24($fp)
	lw  $s3, -20($fp)
	lw  $s2, -16($fp)
	lw  $s1, -12($fp)
	lw  $s0, -8($fp)
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra
	nop	# in delay slot

########################################################################
# .TEXT <showDisplay>
	.text
showDisplay:

# Frame:	$fp, $ra, ...
# Uses:		$s0, $s1, $s2, $s3, $a0, $t1, $t2, $t3, $v0
# Clobbers:	$t1, $t2, $t3, $v0, , $s1, $s2, $s3

# Locals:
#	- `i' in $s1
#	- `j' in $s2
#	- &display[0][0] in $s0
#   - NROWS  in $t1
	# number of columns in display matrix
#   - NDCOLS in $t2
#   -&display[i][j] in $s3
# Structure:
#	showDisplay
#	-> [prologue]
#	-> while_1
#     -> while_2
#   -> exit
#	-> [epilogue]

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	la	$fp, -4($sp)
	sw	$ra, -4($fp)
	sw  $s0, -8($fp)
	sw  $s1, -12($fp)
	sw  $s2, -16($fp)
	sw  $s3, -20($fp)
	addi	$sp, $sp, -24

	#printf(CLEAR)
	la $a0, CLEAR
	li $v0, 4
	syscall
	
	#i = 0
	li $s1, 0
	la $s0, display   # s0 = &display[0][0]
	#set up maximum rows and colnums
	lw $t1, NROWS
	lw $t2, NDCOLS
	while_1:
		bge $s1, $t1, exit
		li $s2, 0
		while_2:
			bge $s2, $t2, exit_inner
			# &display[i][j] = s1*t2 + s2 + &display[0][0]
			mul $t3, $s1, $t2
			add $t3, $t3, $s2
			addu $t3, $t3, $s0     # addu because of address
			lb  $a0, ($t3)
			li  $v0, 11
			syscall
			addi $s2, $s2, 1
		j while_2
		exit_inner:
		lb $a0, new_line
		li $v0, 11
		syscall
		addi $s1, $s1, 1
	j while_1
	
	exit:
	# tear down stack frame
	lw  $s3, -20($fp)
	lw  $s2, -16($fp)
	lw  $s1, -12($fp)
	lw  $s0, -8($fp)
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra
	nop	# in delay slot

########################################################################
# .TEXT <delay>
	.text
delay:

# Frame:	$fp, $ra
# Uses:		$a0, $t0, $t1, $t2, $t3, $t4, $t5
# Clobbers:	$t0, $t1, $t2, $t3, $t4, $t5

# Locals:
#	- `n' in $a0
#	- `x' in $t0
#	- `i' in $t1
#	- `j' in $t2
#	- `k' in $t3

# Structure:
#	delay
#	-> [prologue]
#	-> delay_i_init
#	-> delay_i_cond
#	   -> delay_j_init
#	   -> delay_j_cond
#	      -> delay_k_init
#	      -> delay_k_cond
#	         -> delay_k_step
#	      -> delay_k_f
#	      -> delay_j_step
#	   -> delay_j_f
#	   -> delay_i_step
#	-> delay_i_f
#	-> [epilogue]

# Code:
	sw	$fp, -4($sp)
	la	$fp, -4($sp)
	sw	$ra, -4($fp)
	la	$sp, -8($fp)

	# x <- 0
	move	$t0, $zero
	# These values control the busy-wait.
	li	$t4, 200
	li	$t5, 100

delay_i_init:
	# i = 0;
	move	$t1, $zero
delay_i_cond:
	# i < n;
	bge	$t1, $a0, delay_i_f
	nop	# in delay slot

delay_j_init:
	# j = 0;
	move	$t2, $zero
delay_j_cond:
	# j < DELAY_J;
	bge	$t2, $t4, delay_j_f
	nop	# in delay slot

delay_k_init:
	# k = 0;
	move	$t3, $zero
delay_k_cond:
	# k < DELAY_K;
	bge	$t3, $t5, delay_k_f
	nop	# in delay slot

	# x = x + 1
	addi	$t0, $t0, 1

delay_k_step:
	# k = k + 1
	addi	$t3, $t3, 1
	j	delay_k_cond
	nop	# in delay slot
delay_k_f:

delay_j_step:
	# j = j + 1
	addi	$t2, $t2, 1
	j	delay_j_cond
	nop	# in delay slot
delay_j_f:

delay_i_step:
	# i = i + 1
	addi	$t1, $t1, 1
	j	delay_i_cond
	nop	# in delay slot
delay_i_f:

delay__post:
	# tear down stack frame
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra
	nop	# in delay slot

########################################################################
# .TEXT <isUpper>
	.text
isUpper:

# Frame:	$fp, $ra
# Uses:		$a0
# Clobbers:	$v0

# Locals:
#	- `ch' in $a0
#	- ... $v0 used as temporary register

# Structure:
#	isUpper
#	-> [prologue]
#	[ch cond]
#	   | isUpper_ch_ge_A
#	   | isUpper_ch_le_Z
#	   | isUpper_ch_lt_A
#	   | isUpper_ch_gt_Z
#	-> isUpper_ch_phi
#	-> [epilogue]

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	la	$fp, -4($sp)
	sw	$ra, -4($fp)
	la	$sp, -8($fp)

	# if (ch >= 'A')
	li	$v0, 'A'
	blt	$a0, $v0, isUpper_ch_lt_A
	nop	# in delay slot
isUpper_ch_ge_A:
	# if (ch <= 'Z')
	li	$v0, 'Z'
	bgt	$a0, $v0, isUpper_ch_gt_Z
	nop	# in delay slot
isUpper_ch_le_Z:
	addi	$v0, $zero, 1
	j	isUpper_ch_phi
	nop	# in delay slot

	# ... else
isUpper_ch_lt_A:
isUpper_ch_gt_Z:
	move	$v0, $zero
	# fallthrough
isUpper_ch_phi:

isUpper__post:
	# tear down stack frame
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra
	nop	# in delay slot

########################################################################
########################################################################
# .TEXT <isLower>
	.text
isLower:

# Frame:	$fp, $ra
# Uses:		$a0
# Clobbers:	$v0

# Locals:
#	- `ch' in $a0
#	- ... $v0 used as temporary register

# Structure:
#	isLower
#	-> [prologue]
#	[ch cond]
#	   | isLower_ch_ge_a
#	   | isLower_ch_le_z
#	   | isLower_ch_lt_a
#	   | isLower_ch_gt_z
#	-> isLower_ch_phi
#	-> [epilogue]

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	la	$fp, -4($sp)
	sw	$ra, -4($fp)
	la	$sp, -8($fp)

	# if (ch >= 'a')
	li	$v0, 'a'
	blt	$a0, $v0, isLower_ch_lt_a
	nop	# in delay slot
isLower_ch_ge_a:
	# if (ch <= 'z')
	li	$v0, 'z'
	bgt	$a0, $v0, isLower_ch_gt_z
	nop	# in delay slot
isLower_ch_le_z:
	addi	$v0, $zero, 1
	j	isLower_ch_phi
	nop	# in delay slot

	# ... else
isLower_ch_lt_a:
isLower_ch_gt_z:
	move	$v0, $zero
	# fallthrough
isLower_ch_phi:

isLower__post:
	# tear down stack frame
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra
	nop	# in delay slot

#################################################################### EOF
