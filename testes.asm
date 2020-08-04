.data
	inputFile: .asciiz "/home/gilson/Documents/Computer Organization/mips-project-CO-UTFPR/inputFiles/test.csv" 
	num: .asciiz "12"
	null: .asciiz ""
	buffer_input: .space 1024
	teste: .float 9.1
.text
.main:
	l.s $f12, teste
	la $a0, buffer_input
	jal float2string
	
	#li $v0, 4
	#la $a0, buffer_input
	#syscall
	
	li $v0, 10
	syscall
	#mfhi = remainder mflo = quotient
float2string:
	#f12 = float
	#$a0 = string
	add $sp, $sp, -16
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)
	
	la $s0, buffer_input
	
	#negative numbers exception
	mtc1 $zero, $f16
	cvt.s.w $f16, $f16
	c.lt.s $f12, $f16
	bc1f float2string_negative_continue
	li $t0, -1
	mtc1 $t0, $f16
	cvt.s.w $f16, $f16
	mul.s $f12, $f12, $f16
	li $t0, '-'
	sb $t0, ($s0)
	add $s0, $s0, 1
float2string_negative_continue:			
	#converting float to a word, gets int part
	cvt.w.s $f20, $f12
	mfc1 $s1, $f20 #int part
	
	 
	#geting floor of the float number
	floor.w.s $f21, $f12
	cvt.s.w $f21, $f21
	
	#removing int part
	sub.s $f12, $f12, $f21

	#getting two decimal places
	li $t0, 100
	mtc1 $t0, $f22
	cvt.s.w $f22, $f22
	mul.s $f21, $f12, $f22
	
	cvt.w.s $f21, $f21
	mfc1 $s2, $f21	
	
	li $t4, 10
	div $s2, $t4
	mfhi $t4 
	bne $t4, 9, odd_correction_continue
	add $s2, $s2, 1
	
odd_correction_continue:
	#converting to char
	
	move $a0, $s0
	move $a1, $s1
	jal int2string
	move $s0, $v1 

	#add point
	li $t0, 46
	sb $t0, ($s0)
	add $s0, $s0, 1
	
	move $a0, $s0
	move $a1, $s2
	jal int2string
	
	li $v0, 4
	la $a0,buffer_input
	syscall 
	
	lw $ra, 0($sp)
	add $sp, $sp, 4
	jr $ra
int2string:
	addi $sp, $sp, -16
	sw $ra, 12($sp)
	sw $s2, 8($sp)
	sw $s1, 4($sp)
	sw $s0, 0($sp)
	
	li $s2, 0     #i=0
	move $s0, $a0 #string
	move $s1, $a1 #num
	
	li $t4, 10
	div $s1, $t4
	mflo $t4 #get quotient
	beqz $t4 int2string_continue #(if n/10 != 0)
	move $a1, $t4
	move $a0, $s0
	jal int2string #recursive call of int2string
	move $s2, $v0 #save return
int2string_continue:
	li $t4, 10
	div $s1, $t4
	mfhi $t3 #get remainder
	addi $t3, $t3, '0' #converting to ascii
	add $s0, $s0, $s2 #moving to correct position on string
	sb $t3, ($s0)
	addi $s2, $s2, 1 #update i
	addi $s0, $s0, 1 #string[i+1]
	sb $zero,($s0) #end of string(\0)
	
	
	move $v0, $s2 #return
	move $v1, $s0

	lw $ra, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 16
	jr $ra	
