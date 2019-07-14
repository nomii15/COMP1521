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
zero:   .byte 0
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
	sw	$s0, -8($fp)				# save $s0 to use as ... int maxiters
	sw	$s1, -12($fp)				# save $s1 to use as ... int n
	sw	$s2, -16($fp)				# save $s2 to use as ... int i
	sw	$s3, -20($fp)				# save $s3 to use as ... int j
	sw	$s4, -24($fp)				# save $s4 to use as ... int nn
	addi	$sp, $sp, -28			# reset $sp to last pushed item

	lw  $s7, N						#initialising global variable N, into $s7
    la  $s6, board					#initialising MemAdd[board[0][0]] into $s6
	la  $s5, newBoard				#loading starting address of newboard into $s5

    la 	$a0, msg1
    li 	$v0, 4
    syscall             			#printf("Iterations: ")
    
    li	$v0, 5
	syscall			    			# scanf("%d", into $v0)
	move  $s0, $v0    				#move scanned number into $s0 aka maxiters

    li $s1, 1           			#initialise n = 1
top_for_loop:
    bgt $s1, $s0 end_top 			#break outer loop if n > maxiters ($s1 > $s0)
    
    li $s2, 0           			#initialise i = 0
mid_for_loop:
    bge $s2, 15 end_mid 			#break mid loop if i >= N (N #defined in board.h as 15)
    
    li $s3, 0           			#initialise j = 0
low_for_loop:
    bge $s3, 15 end_mid 			#break mid loop if j >= N (N #defined in board.h as 15)
    
    move $a0, $s2         			#loading the current value of i into $a0 for use in
                        			#neighbours function
    move $a1, $s3         			#loading the current value of j into $a1 for use in
                        			#neighbours function
    jal neighbours
    nop
	move $s4, $v0					#move the returned value of nn into $s4
	
	li $t9, 4						#4 bytes in an int
								    	
	mul $t0, $s2, $s7  				#$t0 = current row * total number of cols ((i) * N)
    mul $t0, $t0, $t9  				#$t0 = t0 * 4 -bytes of number of matrix spaces traversed
    mul $t1, $s3, $t9  				#$t1 = current column * 4 bytes ((j) * 4)

	add $t0, $t0, $t1				#total number of bytes traversed
	
	la  $t1, ($s6)					#loading address at $s6 (MemAdd[board[0][0])
	add $t1, $t1, $t0				#we are now at the address we want to check - MemAdd[board[0][0] + offset

	lw  $t2, ($t1)					#load into t0 the byte at memaddress($t1)
	
	move  $a0, $t2					#loading into $a0 (first parameter of decideCell function (int old))
	move  $a1, $s4					#loading into $a1 (second parameter of decideCell function (int nn)) 
    
	jal decideCell					#will return with either a 0 or 1. Now need to insert return value in correct position
	nop								#RECALUCLATING BYTE OFFSET INCASE $t0 HAS BEEN ALTERED IN OTHER FUNCTIONS
	mul $t0, $s2, $s7  				#$t0 = current row * total number of cols ((i) * N)
    mul $t0, $t0, $t9  				#$t0 = t0 * 4 -bytes of number of matrix spaces traversed
    mul $t1, $s3, $t9  				#$t1 = current column * 4 bytes ((j) * 4)

	add $t0, $t0, $t1				#total number of bytes traversed

	add $t3, $s5, $t0				#$s5 holds MEM-ADD of the start of the new board. $t3 = memadd(new) + offset
									
	move  $t3, $v0					#$v0 holds the 0 or 1 and we load that into the $t3
	
    addi $s3, $s3, 1    			#increment j by 1
    j low_for_loop
end_low:
    addi $s2, $s2, 1    			#increment i by 1
    j mid_for_loop
end_mid:
    la $a0, msg2
    li $v0, 4
    syscall             			#printf("=== After iteration ")
    
    la $a0, ($s1)
    li $v0, 4
    syscall             			#printf("%d") ---- current value of n
    
    la $a0, msg3
    li $v0, 4
    syscall             			#printf(" ===")
    
    la $a0, eol
    li $v0, 4
    syscall             			#printf("\n")
    
    jal copyBackAndShow   			#jump to label CopyBackandShow
    nop
#return_CPAS:            			#return to label after calling function CopyBackandShow
   
    addi $s1, $s1, 1    			#increment n by 1
    j top_for_loop
end_top:
    
    li $v0, 0           			#return 0    

main__post:
    lw  $s4, -24($fp)
    lw  $s3, -20($fp)
    lw  $s2, -16($fp)
    lw  $s1, -12($fp)
    lw  $s0, -8($fp)
    lw  $ra, -4($fp)
    la  $sp, 4($fp)
    lw  $fp, ($fp)
	jr	$ra

	# Put your other functions here

decideCell:
	sw  $fp, -4($sp)
	la 	$fp, -4($sp)
	sw  $ra, -4($fp)
	addi  $sp, $sp, -8
	
	li  $t2, 1						#used to check conditions
	li  $t3, 2						#used to check conditions
	li  $t4, 3						#used to check conditions

	bne $a0, $t2, big_else_if
	bge $a1, $t3, small_else_if
	li  $v0, 0
	j finish
small_else_if:						#else if (nn == 2 || nn == 3)

	beq $a1, $t3, found		
	beq $a1, $t4, found
	j small_else
found:
	li  $v0, 1
	j finish
small_else:

	li  $v0, 0
	j finish	
big_else_if:						#else if (nn == 3)

	bne  $a1, $t4, big_else
	li  $v0, 1
	j finish
big_else:

	li  $v0, 0

finish:

	lw  $ra, -4($sp)
	la  $sp, 4($fp)
	lw  $fp, ($fp)
	jr  $ra


neighbours:
    sw	$fp, -4($sp)				# push $fp onto stack
	la	$fp, -4($sp)				# set up $fp for this function
	sw	$ra, -4($fp)				# save return address
	sw  $s2, -8($fp)
	sw  $s3, -12($fp)
	addi  $sp, $sp, -16
	
	li $t2, 0                       #initialising $t2 (nn) to be 0
	
	li $t8, 1						#to be used for condition ----> if(board[i + x][j + y] == 1) nn++;
	li $t9, 4						#4 bytes in an int
	
	li $t3, -1                      #initialising $t3 (x) to be -1
neigh_top_loop:
    bgt $t3, 1 neigh_top_end        #if x > 1, break
    
    li $t4, -1                      #initialising $t3 (y) to be -1
neigh_bottom_loop:
    bgt $t4, 1 neigh_bottom_end     #if y > 1, break
    
	add $t5, $a0, $t3				#$t5 = x + i
	add $t6, $a1, $t4				#$t6 = y + j
	addi $t7, $s7, -1				#$t7 = N - 1

	blt $t5, $zero, iterate			#i + x < 0 goto next iteration
	bgt $t5, $t7, iterate			#i + x > N - 1 goto next iteration
	blt $t6, $zero, iterate			#j + y < 0 goto next iteration
	bgt $t6, $t7, iterate			#j + y > N - 1 goto next iteration
	beq $t3, $zero, iterate			#x == 0 goto next iteration
	beq $t4, $zero, iterate			#y == 0 goto next iteration
	
	mul $t0, $t5, $s7  				# t0 = current row * total number of cols ((i + x) * N)
    mul $t0, $t0, $t9  				# t0 = t0 * 4 -bytes of number of matrix spaces traversed
    mul $t1, $t6, $t9  				# t1 = current column * 4 bytes ((j + y) * 4)

	add $t0, $t0, $t1				#total number of bytes traversed
	
	la  $t1, ($s6)					#loading address at $s6 (MemAdd[board[0][0])
	add $t1, $t1, $t0				#we are now at the address we want to check - MemAdd[board[0][0] + offset

	lw  $t0, ($t1)					#load into t0 the byte at memaddress($t1)
	
	bne $t0, 1, iterate				#not equal to 1? goto next iteration
	
	addi $t2, $t2, 1				#increment nn
	j neigh_bottom_loop
iterate:
    addi $t4, $t4, 1                #increment y by 1
neigh_bottom_end:
    
    addi $t3, $t3, 1                #increment x by 1
    j neigh_top_loop
neigh_top_end:

	move $v0, $t2

	lw  $s3, -12($fp)
    lw  $s2, -8($fp)
    lw  $ra, -4($fp)
    la  $sp, 4($fp)
    lw  $fp, ($fp)
	jr	$ra
	

copyBackAndShow:	
	sw	$fp, -4($sp)				# push $fp onto stack
	la	$fp, -4($sp)				# set up $fp for this function
	sw	$ra, -4($fp)				# save return address
	addi $sp, $sp, -8

	li $t0, 0                   	#initialise i($t0) to 0
loop_out:
    bge $t0, $s7 end_loop_out    	#break loop if i >= N
    
    li $t1, 0                   	#initialise j($t1) to 0
loop_in:
    bge $t1, $s7 end_loop_in     	#break loop if j >= N
	
	mul $t2, $t0, $s7  				#$t2 = current row * total number of cols ((i) * N)
    mul $t2, $t2, $t9  				#$t2 = t2 * 4 -bytes of number of matrix spaces traversed
    mul $t3, $t1, $t9  				#$t3 = current column * 4 bytes ((j) * 4)

	add $t2, $t2, $t3				#total number of bytes traversed
	
	la  $t4, ($s5)					#loading address at $s5 (MemAdd[newboard[0][0])
	add $t4, $t4, $t2				#we are now at the address we want to check - MemAdd[newboard[0][0]] + offset

	lw  $t5, ($t4)					#load into t5 the byte at memaddress($t4)

	la  $t4, ($s6)					#loading address at $s6 (MemAdd[board[0][0])
	add $t4, $t4, $t2				#we are now at the address we want to check - MemAdd[board[0][0]] + offset

	move  $t4, $t5					#copy address at newboard[i][j] to board[i][j]

	bne $t4, $zero else				#if board[i][j] is not zero jump to else statement
	
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
    
    addi $t0, $t0, 1            	#increment n by 1
    j loop_out
end_loop_out:	

    #j return_CPAS
	lw  $ra, -4($fp)
    la  $sp, 4($fp)
    lw  $fp, ($fp)
	jr	$ra
