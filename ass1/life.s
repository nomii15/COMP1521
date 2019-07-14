# board1.s ... Game of Life on a 10x10 grid

	.data

N:	.word 10  # gives board dimensions

board:
	.byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0
	.byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0

newBoard: .space 100
# COMP1521 19t2 ... Game of Life on a NxN grid
#
# Written by <<NADIR, NORMORAD>>, June 2019

## Requires (from `boardX.s'):
# - N (word): board dimensions
# - board (byte[][]): initial board state
# - newBoard (byte[][]): next board state
## Global data
	.data
one:    .byte 1
zeero:  .byte 0
msg1:	.asciiz "# Iterations: "
msg2:	.asciiz "=== After iteration "
msg3:   .asciiz " ==="
msg4:   .asciiz "."
msg5:   .asciiz "#"
eol:	.asciiz "\n"

## Provides:
	.globl	main
	.globl	decideCell
	.globl	neighbours
	.globl	copyBackAndShow


########################################################################
# .TEXT <main>
	.text
main:

# Frame:	...
# Uses:		...
# Clobbers:	...

# Locals:	...

# Structure:
#	main
#	-> [prologue]
#	-> ...
#	-> [epilogue]

# Code:

    sw	$fp, -4($sp)				# push $fp onto stack
	la	$fp, -4($sp)				# set up $fp for this function
	sw	$ra, -4($fp)				# save return address
	addi	$sp, $sp, -8			# reset $sp to last pushed item	

    la 	$a0, msg1
    li 	$v0, 4
    syscall             			#printf("Iterations: ")
    
    li	$v0, 5
	syscall			    			# scanf("%d", into $v0)
	move  $s0, $v0    				#$s0 = maxiters
	
	li  $s1, 1						#$s1 = n = 1
	li  $s2, 0						#$s2 = i = 0
	li  $s3, 0						#$s3 = j = 0
	lw  $s4, N						#$s4 = N
	li  $s5, 0						#$s5 = nn = 0
	#li  $s6, -1						#$s6 = x = -1
	#li  $s7, -1						#$s7 = y = -1

    li $s1, 1           			#initialise n = 1
top_for_loop:
    bgt $s1, $s0 end_top 			#break outer loop if n > maxiters ($s1 > $s0)    
    li $s2, 0           			#initialise i = 0

mid_for_loop:
    bge $s2, $s4 end_mid 			#break mid loop if i >= N    
    li $s3, 0           			#initialise j = 0

low_for_loop:
    bge $s3, $s4 end_mid 			#break mid loop if j >= N
    move $a0, $s2
    move $a1, $s3
    jal neighbours
    nop
    move $s5, $v0                   #copy value of nn from $v0(found in neighbours) into $s5
return_neigh:								    	
	mul $t0, $s2, $s4  				#$t0 = current row * total number of cols ((i) * N)
	add $t0, $t0, $s3				#total number of bytes traversed (iN) + j
	
	lb  $t1, board($t0)				#loading byte at address MemAdd[board[0][0] + offset]
	lb  $t8, one                   #let $t8 = 1(byte)
    beq  $t1, $t8, make_one         #if $t1(byte) = $t8(byte) 
    li   $t9, 0                     #set $t9 = 0 (int)
    j end_make_one
make_one:
    li $t9, 1                       #set $t9 = 1 (int)
end_make_one:
    move $a0, $t9 
    move $a1, $s5
	jal decideCell					#will return with either a 0 or 1. Now need to insert return value in correct position
    nop
return_decide:
    move $t2, $v0							
	mul  $t1, $s2, $s4				#$t1 = current row * total number of cols ((i) * N)
	add  $t1, $t1, $s3				#total number of bytes traversed (iN) + j	
	sb  $t2, newBoard($t1)			#set the byte held in $t2 from decide_cell, into MemAddress(newBoard[i][j] + offset($t1))
	
    addi $s3, $s3, 1    			#increment j by 1
    j low_for_loop
end_low:
    addi $s2, $s2, 1    			#increment i by 1
    li  $s3, 0						#reset j = 0
    j mid_for_loop
end_mid:
    la $a0, msg2
    li $v0, 4
    syscall             			#printf("=== After iteration ")
    
    move $a0, $s1
    li $v0, 1
    syscall             			#printf("%d") ---- current value of n
    
    la $a0, msg3
    li $v0, 4
    syscall             			#printf(" ===")
    
    la $a0, eol
    li $v0, 4
    syscall             			#printf("\n")
    
    j copyBackAndShow   			#jump to label CopyBackandShow
return_CPAS:   
    addi $s1, $s1, 1    			#increment n by 1
    li  $s2, 0						#reset i = 0
    li  $s3, 0						#reset j = 0
    j top_for_loop
end_top:
    
    li $v0, 0           			#return 0    

main__post:
    lw  $ra, -4($fp)
    la  $sp, 4($fp)
    lw  $fp, ($fp)
	jr	$ra






decideCell:
    sw	$fp, -4($sp)				# push $fp onto stack
	la	$fp, -4($sp)				# set up $fp for this function
	sw	$ra, -4($fp)				# save return address
	addi	$sp, $sp, -8			# reset $sp to last pushed item
    #lb   $t8, one                   #let $t8 = 1(byte)
    #beq  $t1, $t8, make_one         #if $t1(byte) = $t8(byte) 
    #li   $t9, 0                     #set $t9 = 0 (int) 
#if_statements:
	bne  $a0, 1, big_else_if		#old = 1?
	beq  $a1, 2, char_one			#nn = 2
	beq  $a1, 3, char_one			#nn = 3
	
char_zero:	
	lb  $t2, zeero    				#$t2(ret) = 0
	j end_char_zero
	#jr $ra
	#nop
char_one:
	lb  $t2, one
	#j return_decide					#$t2(ret) = 1
	#jr $ra
	#nop
big_else_if:						#else if (nn == 3)
	beq  $a1, 3, char_one			#nn = 3
	j char_zero
end_char_zero:
#make_one:
    #li $t9, 1                       #set $t9 = 1 (int)
    #j if_statements 
    move $v0, $t2
    
    lw  $ra, -4($fp)
    la  $sp, 4($fp)
    lw  $fp, ($fp)
	jr	$ra






neighbours:
    sw	$fp, -4($sp)				# push $fp onto stack
	la	$fp, -4($sp)				# set up $fp for this function
	sw	$ra, -4($fp)				# save return address
	addi	$sp, $sp, -8			# reset $sp to last pushed item
	
    li $t2, 0                       #temp nn = 0	
	li $t0, -1                      #x = -1

neigh_top_loop:
    bgt $t0, 1 neigh_top_end        #if x > 1, break    
    li $t1, -1                      #y = -1

neigh_bottom_loop:
    bgt $t1, 1 neigh_bottom_end     #if y > 1, break
    
	add $t5, $a0, $t0				#$t5 = x + i
	add $t6, $a1, $t1				#$t6 = y + j
	addi $t7, $s4, -1				#$t7 = N - 1

	blt $t5, $zero, iterate			#i + x < 0 goto next iteration
	bgt $t5, $t7, iterate			#i + x > N - 1 goto next iteration
	blt $t6, $zero, iterate			#j + y < 0 goto next iteration
	bgt $t6, $t7, iterate			#j + y > N - 1 goto next iteration
	beq $t0, $zero, check_y			#x == 0, check y
	j end_check_y	

check_y:
	beq $t1, $zero, iterate			#y == 0 goto next iteration

end_check_y:	
	mul  $t4, $s4, $t5				#$t4 = current row * Number of columns - ((i + x) * N)
	add  $t4, $t4, $t6				#$t4 = $t4 + (j + y)
	
	lb  $t3, board($t4)				#loading the byte at MemAddress board + offset ($t4)
	lb  $t4, one  					#loading one(1) into $t4
	
	beq $t3, $t4, nn_plus			#jump to increment nn if condition passes
	j iterate
	
nn_plus:
	addi $t2, $t2, 1

iterate:
    addi $t1, $t1, 1                #increment y by 1
	j neigh_bottom_loop
	
neigh_bottom_end:    
    addi $t0, $t0, 1                #increment x by 1
    li  $t1, -1						#reset y = -1
    j neigh_top_loop
    
neigh_top_end:
    move $v0, $t2
	#j return_neigh
    lw  $ra, -4($fp)
    la  $sp, 4($fp)
    lw  $fp, ($fp)
	jr	$ra






copyBackAndShow:	
	li $t0, 0                   	#initialise i($t0) to 0

loop_out:
    bge $t0, $s4 end_loop_out    	#break loop if i >= N    
    li $t1, 0                   	#initialise j($t1) to 0
    
loop_in:
    bge $t1, $s4 end_loop_in     	#break loop if j >= N
	
	mul $t3, $s4, $t0				#$t3 = current row * total number of cols ((i) * N)
	add $t3, $t3, $t1				#$t3 = itself + current column

	lb  $t4, newBoard($t3)			#load into $t4 the byte at location newboard[0][0] + offset
	sb  $t4, board($t3)				#save that byte into the location board[0][0] + offset
	
	lb  $t5, zeero					#load into $t5 a byte 0, to compare in the if conditions
	bne $t4, $t5, else
	
	la  $a0, msg4
	li  $v0, 4						#printf(".")
	syscall

	j end_else	

else:
	la  $a0, msg5
	li  $v0, 4						#printf("#")
	syscall

end_else:
    addi $t1, $t1, 1            	#increment j by 1
    j loop_in

end_loop_in:
    la $a0, eol             
    li $v0, 4
    syscall                     	#printf("\n")
    
    addi $t0, $t0, 1            	#increment i by 1
    li  $t1, 0						#reset j = 0
    j loop_out

end_loop_out:	
	j return_CPAS
