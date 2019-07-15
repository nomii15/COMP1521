# COMP1521 19t2 ... Game of Life on a NxN grid
#
# Written by <<NADIR, NORMORAD>>, June 2019

## Requires (from `boardX.s'):
# - N (word): board dimensions
# - board (byte[][]): initial board state
# - newBoard (byte[][]): next board state
## Global data
	.data
msg1:   .asciiz "# Iterations: "
msg2:   .asciiz "=== After iteration "
msg3:   .asciiz " ===\n"
eol:    .asciiz "\n"
hash:   .asciiz "#"
dot:    .asciiz "."

one:        .byte 1
zeero:      .byte 0

maxiter:    .word 1
nn:         .word 0

ra_main:    .space 4
ra_CBAS:    .space 4
ra_neigh:   .space 4
ra_decide:  .space 4
ra_preCBAS: .space 4

	.text
	.globl	main
	.globl	decideCell
	.globl	neighbours
	
###############################MAIN###################################
main:
	sw   $ra, ra_main
	
	la   $a0, msg1		
	li   $v0, 4
	syscall                     #printf("# Iterations: ");

	li   $v0, 5				
	syscall
    move  $s3, $v0              # maxiter
    
    lw   $s4, N 				#N
	
    li   $s0, 1					#n = 1
top_loop:							
	bgt  $s0, $s3, end_top          #n > maxiter
    li  $s1, 0
mid_loop:
	bge  $s1, $s4, end_mid_loop     #i >= N
	li   $s2, 0                     #j = 0

low_loop:
	bge  $s2, $s4, end_low_loop     #j >= N

	jal  neighbours
	jal  decideCell 			

	addi $s5, $s5, 1                #matrix_counter++;
	addi $s2, $s2, 1                #j++;
	j  low_loop
end_low_loop:
	addi $s1, $s1, 1                #i++;
	j  mid_loop
end_mid_loop:	
	jal  printf
	jal  CopyBackAndShow
	
	addi $s0, $s0, 1                #n++;
	li   $s5, 0                     #matrix_counter = 0;
	j  top_loop
end_top:
	lw   $ra, ra_main
	jr   $ra
#################################END MAIN#############################
################################DecideCell############################
decideCell:
    sw  $ra, ra_decide
    
    lb  $t2, board($s5)
	lb  $t0, one
    lw   $t1, nn
    
    bne  $t2, $t0, big_else_if
    beq  $t1, 2, char_one
    beq  $t1, 3, char_one
char_zero:    
    lb   $t0, zeero
	sb   $t0, newBoard($s5)
	j finish
char_one:    
    lb   $t0, one
	sb   $t0, newBoard($s5)
	j finish
big_else_if:
    beq  $t1, 3, char_one
    j char_zero  
finish:
    lw   $ra, ra_decide
	jr   $ra
################################END DecideCell##############################
###################################Neigbours################################
neighbours:
    sw   $ra, ra_neigh

    li   $t0, 0             #t0 = 0
    sw   $t0, nn            #nn = t0 = 0

    lw   $t5, N             #N
    addi $t5, $t5, -1       #N - 1

    li   $t7, -1                    #x = -1
x_loop:
	bgt  $t7, 1, end_x_loop         #x > 1?
    li   $t6, -1                    #reset y = -1
y_loop:
	bgt  $t6, 1, end_y_loop         #y > 1?

	li   $t0, 0
	add  $t0, $s1, $t7              #i + x
	blt  $t0, $zero, iterate        #i + x < 0
	bgt  $t0, $t5, iterate          #i + x > N - 1

	li   $t0, 0
	add  $t0, $s2, $t6 
	blt  $t0, $zero, iterate 	    #j + y < 0
	bgt  $t0, $t5, iterate          #j + y > N - 1

	li   $t0, 0
	bne  $t7, $t0, board_check	    # x == 0?
	bne  $t6, $t0, board_check      # y == 0?
	j  iterate
	
board_check:
	lw   $t1, N
	mul  $t9, $t7, $t1  	#(i + x) * N
	add  $t9, $t9, $t6  	#((i + x) * N) + (j + y)
	add  $t3, $s5, $t9  	#((i + x) * N) + (j + y) + matrix counter
	
	lb   $t4, board($t3)    #board[i+x][j+y]
	lb   $t0, one           #t0 = 1(byte)
	
	bne  $t0, $t4, iterate  #board[i+x][j+y] == 1(byte)?
	
    lw   $t8, nn            #t8 = nn
    addi $t8, $t8, 1        #t8++
    sw   $t8, nn            #nn = t8
	j  iterate

iterate:
	addi $t6, $t6, 1        #y++
	j  y_loop

end_y_loop:
	addi $t7, $t7, 1        #x++
	j 	 x_loop
end_x_loop:
	lw   $ra, ra_neigh
	jr   $ra
###############################END Neigbours################################
##################################printf####################################
printf:
    sw  $ra, ra_preCBAS
    
    la   $a0, msg2
	li   $v0, 4
	syscall             #printf("=== After iteration ")
	
	move $a0, $s0
	li   $v0, 1
	syscall             #printf("%d")
	
	la   $a0, msg3
	li   $v0, 4
	syscall             #printf(" ===\n")
    
    lw  $ra, ra_preCBAS
    jr  $ra
###################################END_PRINTF################################
######################################CBAS###################################
CopyBackAndShow:
    sw   $ra, ra_CBAS

	li   $s5, 0                 #matrix counter = 0
    li   $s1, 0                 #i = 0  
i_loop:
	bge  $s1, $s4, end_i_loop
	li   $s2, 0                 #j = 0
j_loop:
	bge  $s2, $s4, end_j_loop

	lb   $t1, newBoard($s5)     #t1 = newboard(cell)
	sb   $t1, board($s5)        #board(cell) = t1
	lb   $t0, zeero             #t0 = one(byte)
	beq  $t1, $t0, put_dot      #t0 = t1?
put_hash:
	lb   $a0, hash
	li   $v0, 11
	syscall                     #printf("#");
	
	j  next_col 
put_dot:
	lb   $a0, dot
	li   $v0, 11
	syscall                     #printf(".");        
next_col:
	addi $s5, $s5, 1            #matrix_counter++
	addi $s2, $s2, 1            #j++;
	
	j  j_loop
end_j_loop:
	la   $a0, eol
	li   $v0, 4
	syscall                     #printf("\n");
	
	addi $s1, $s1, 1            #i++;
	j 	 i_loop
end_i_loop:
	lw   $ra, ra_CBAS
	jr   $ra
###################################END_CBAS################################
