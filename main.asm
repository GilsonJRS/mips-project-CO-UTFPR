.eqv buffer_input_length 1024
.data 
	inputFile: .asciiz "/home/gilson/Documents/Computer Organization/mips-project-CO-UTFPR/inputFiles/test.csv" 
	outputFile: .asciiz "/home/gilson/Documents/Computer Organization/mips-project-CO-UTFPR/outputFiles/test.csv"
	inputFile_error_msg: .asciiz "error on open input file"
	outputFile_error_msg: .asciiz "error on create output file"
	invalid_x_input: .asciiz "invalid x value"
	comma: .asciiz ","
	lineBreak: .asciiz "\n"
	null: .asciiz ""
    	.word 0
    	buffer_input: .space 1024
    	.word 0
    	buffer_int: .byte 100
    	.word 0
    	buffer_float: .byte 100
    	.word 0
    	inputFilePointer: .space 4
    	.word 0
    	alreadyRead: .space 500000
.text
main:
    	jal mean
#----------------------------------------------
#mean function
#$a0 = input file
#$a1 = output file
#----------------------------------------------
mean:
	add $sp, $sp, -12
	sw $ra, 8($sp)
	sw $s1, 4($sp)
	sw $s0, 0($sp)
	
	li $t0, 0
	sw $t0, inputFilePointer #set position on file = 0
	
	#add $s1, $a1, $zero #$s1 = output file
	
	#this nested loop get one line and go to
	#the file, if a x equal the actual x is
	#find they are added for the mean
mean_outer_loop:
	#open inputFile
    	li $v0, 13
    	la $a0, inputFile
    	add $a1, $zero, $zero	#$a1 = 0(read)
    	add $a2, $zero, $zero
    	syscall
    	add $s0, $v0, $zero
    	bltz $s0, inputFile_error
    	
    	#adjust file pointer
	move $a0, $s0
	lw $a1, inputFilePointer
	jal fseek
	beqz $v0, mean_end_outer_loop
	
	#get int(x)
	move $a0, $s0
	li $a1, 1 #update inputFilePointer
	jal extract_int
	add $s4, $v0, $zero #extracted int
	
	#get float(y)
	move $a0, $s0
	li $a1, 1
	jal extract_float
	mtc1 $zero, $f20 #set $f20 to zero
	add.s $f20, $f20, $f0 #extracted float

	mtc1 $zero, $f22
	add.s $f22, $f22, $f20
	li $s6, 1
mean_inner_loop:
	move $a0, $s0
	jal extract_int
	add $s5, $v0, $zero #extracted int
	beqz $a0, div_else
	
	move $a0, $s0
	jal extract_float
	mtc1 $zero, $f21
	add.s $f21, $f21, $f0 #extracted float
	beq $a0, 1, mean_end_inner_loop
	
	bne $s4, $s5, x_else #verify if another x equal the actual x is find
	add.s $f22, $f21, $f20 #if is find, add y to $f22
	addi $s6, $s6, 1 #and increment the counter
	x_else:
	j mean_inner_loop
mean_end_inner_loop:
	beq $s6, 1, div_else
	mtc1 $s6, $f23
	div.s $f22, $f22, $f23 
	div_else:
	#print x($s4) and y($f22)
	#close file
	li $v0, 16
    	add $a0, $s0, $zero
    	syscall
	j mean_outer_loop
mean_end_outer_loop:

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	add $sp, $sp, 12
	jr $ra
#----------------------------------------------
#extract int
#$a0 = input file
#$a1 = update pointer flag
#$v0 = int extracted
#$v1 = end of file flag
#----------------------------------------------
extract_int:	
	add $sp, $sp, -16
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)
	
	move $s0, $a0 #file descriptor
	move $s2, $a1 #update file pointer flag
	
	li $v1, 0
	la $t0, buffer_input
	la $t3, buffer_int
	lw $s1, inputFilePointer
	
	#*to do: remove spaces
	li $v0, 14
    	add $a0, $s0, $zero
	la $a1, buffer_input
	li $a2, 1
	syscall
	addu $s1, $s1, 1
	beqz $v0, extract_int_end_of_file_flag
    	
	lb $t2, ($t0)
    	#get negative signal
	bne $t2, 45, string_int_copy
	sb $t2, ($t3)
	add $t3, $t3, 1
	j string_int_copy_continue
string_int_copy:
	lb $t2, ($t0)
	blt $t2, 48, end_string_int_copy #0-9 range
	bgt $t2, 57, end_string_int_copy #0-9 range    	
	sb $t2, ($t3)
	add $t3, $t3, 1
string_int_copy_continue:
	li $v0, 14
    	add $a0, $s0, $zero
	la $a1, buffer_input
	li $a2, 1
	syscall
	addu $s1, $s1, 1
		
	j string_int_copy
end_string_int_copy:
	lb $t2, ($t0)
	beq $t2, 10, end_string_int_file_descriptor_adjustment
	beq $t2, 44, end_string_int_file_descriptor_adjustment
	
	li $v0, 14
    	add $a0, $s0, $zero
	la $a1, buffer_input
	li $a2, 1
	syscall
	addu $s1, $s1, 1
	j end_string_int_copy
end_string_int_file_descriptor_adjustment:
	lb $t2, null #load null terminator
	sb $t2, ($t3) #stores null to flag buffer_int end
	
	la $a0, buffer_int
	jal string_to_int
	move $v0, $v0 #return int

	j extract_int_exit
extract_int_end_of_file_flag:
	li $v1, 1
extract_int_exit:
	bne $s2, 1, extract_int_exit_2 
	sw $s1, inputFilePointer
extract_int_exit_2:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	add $sp, $sp, 16
	jr $ra
#----------------------------------------------
#extract float
#$a0 = input file
#$f0 = return float
#$v1 = end of file flag
#----------------------------------------------
extract_float:
	add $sp, $sp, -8
	sw $s0, 4($sp)
	sw $ra, 0($sp)
	
	move $s0, $a0 #file descriptor
	
	la $t0, buffer_input
	la $t3, buffer_float
	lw $t4, inputFilePointer
	#*to do: remove spaces
	li $v0, 14
	add $a0, $s0, $zero
	la $a1, buffer_input
	li $a2, 1
	syscall
	add $t4, $t4, 1
	
	lb $t2, ($t0)
	bne $t2, 45, string_float_copy
	sb $t2, ($t3)
	j string_float_continue
string_float_copy:
	lb $t2, ($t0)
	beq $t2, 46, string_float_continue
	blt $t2, 48, end_string_float_copy
	bgt $t2, 57, end_string_float_copy
string_float_continue:
	sb $t2, ($t3)
	add $t3, $t3, 1
	
	li $v0, 14
	add $a0, $s0, $zero
	la $a1, buffer_input
	li $a2, 1
	syscall
	add $t4, $t4, 1
	beqz $v0, end_string_float_file_descriptor_adjustment_flag_end
	
	j string_float_copy
end_string_float_copy:
	lb $t2, ($t0)
	beq $t2, 10, end_string_float_file_descriptor_adjustment
	
	li $v0, 14
	add $a0, $s0, $zero
	la $a1, buffer_input
	li $a2, 1
	syscall
	add $t4, $t4, 1

	j end_string_float_copy	
end_string_float_file_descriptor_adjustment_flag_end:
	li $s0, 1
end_string_float_file_descriptor_adjustment:
	lb $t2, null
	sb $t2, ($t3)
	
	la $a0, buffer_float
	jal string_to_float
	mov.s $f0, $f0
	
	move $v1, $t4
	seq $a0, $s0, 1
end_string_float_file_exit:	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	add $sp, $sp, 8
	jr $ra
#----------------------------------------------
#print on output file
#$a0
#$v0
#$v1
#----------------------------------------------
print_on_file:

#----------------------------------------------
#string_to_int function
#$a0 = address of string
#$v0 = integer 
#----------------------------------------------
string_to_int:
	add $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $t0, $a0
	li $v0, 0 #initializing number with 0
	li $t1, 0 #flag to negative numbers
	
	#load the first byte, if is a 
	#- sign changes the flag to 1 and
	#go to the next char
	lb $t2, ($t0) 
	bne $t2, 45, string2int_loop
	li $t1, 1
	add $t0, $t0, 1

	string2int_loop:
	lb $t2, ($t0)
	#verificating if the caracter
	#is in the range of ascii number
	#representation (0(4) to 9(57))
	blt $t2, 48, string2int_end_loop #throw exception?
	bgt $t2, 57, string2int_end_loop #throw exception?

	mul $v0, $v0, 10 
	add $v0, $v0, $t2
	sub $v0, $v0, 48 #remove 48 for convert to int
	
	add $t0, $t0, 1
	
	j string2int_loop
string2int_end_loop:
	bne $t1, 1, negative_flag_else
	sub $v0, $zero, $v0
	negative_flag_else:
	
	lw $ra, 0($sp)
	add $sp, $sp, 4
	jr $ra
#----------------------------------------------
#string_to_float function
#$a0 = address of string
#$f0 = float 
#----------------------------------------------
string_to_float:
	add $sp, $sp, -4
	sw $ra, 0($sp)
	
	add $v0, $zero, $zero #resetting for later use
	move $t0, $a0
	mtc1 $zero, $f0 #initializing number with 0
	li $t1, 0 #flag to negative numbers
	
	li $t3, 10
	mtc1 $t3, $f5 #for decimal part conversion
	cvt.s.w $f5, $f5
	mtc1 $t3, $f8
	cvt.s.w $f8, $f8
	
	#load the first byte, if is a 
	#- sign changes the flag to 1 and
	#go to the next char
	lb $t2, ($t0) 
	bne $t2, 45, string_to_float_str2int_loop
	li $t1, 1
	add $t0, $t0, 1

	string_to_float_str2int_loop:
	lb $t2, ($t0)
	#verificating if the caracter
	#is in the range of ascii number
	#representation (0(4) to 9(57))
	beq $t2, 46, float_dot
	blt $t2, 48, string_to_float_str2int_end_loop #throw exception
	bgt $t2, 57, string_to_float_str2int_end_loop #throw exception

	mul $v0, $v0, 10 
	add $v0, $v0, $t2
	sub $v0, $v0, 48 #remove 48 for convert to int
	
	mtc1 $v0, $f0 #move interger number to the FP register
	cvt.s.w $f0, $f0 #converting to float
	add $t0, $t0, 1
	j string_to_float_str2int_loop
float_dot:
	add $t0, $t0, 1
	lb $t2, ($t0)
	blt $t2, 48, string_to_float_str2int_end_loop
	bgt $t2, 57, string_to_float_str2int_end_loop
	
	sub $t2, $t2, 48
	#move to float register
	mtc1 $t2, $f6
	cvt.s.w $f6, $f6
	
	div.s $f7, $f6, $f5
	add.s $f0, $f0, $f7
	
	mul.s $f5, $f5, $f8
	j float_dot
string_to_float_str2int_end_loop:
	#if negative flat true invert signal
	bne $t1, 1, str2float_negative_flag_else
	mtc1 $zero, $f4
	sub.s $f0, $f4, $f0
	str2float_negative_flag_else:
	
	lw $ra, 0($sp)
	add $sp, $sp, 4
	jr $ra
#----------------------------------------------
#fseek:
#set the file descriptor to a new position
#arguments:
#$a0 = file descriptor
#$a1 = number of bytes to offset 
#return:
#$v0 = end of file flag(0 if eof)
#----------------------------------------------
fseek:
	add $sp, $sp, -8
	sw $s1, 4($sp)
	sw $s0, 0($sp)
	
	#file descriptor
	move $s0, $a0
	beqz $a1, end_fseek #if numbers of bytes to offset is equal 0, exit
	
	#number of bytes
	move $s1, $a1
	
	ble $s1, buffer_input_length, end_fseek_greater_loop#if number of bytes to offset < buffer
fseek_greater_loop:
	sub $s1, $s1, buffer_input_length
	li $v0, 14
    	move $a0, $s0
	la $a1, buffer_input
	li $a2, buffer_input_length
	syscall
	beqz $v0, end_fseek #end of file reach
	
	bgt $s1, buffer_input_length, fseek_greater_loop#$a1 > buffer
end_fseek_greater_loop:
	li $v0, 14
    	move $a0, $s0
	la $a1, buffer_input
	move $a2, $s1
	syscall
end_fseek:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	add $sp, $sp, 8
	jr $ra
#----------------------------------------------
#error's labels
#----------------------------------------------
inputFile_error:
	li $v0, 4
	la $a0, inputFile_error_msg
	syscall
	j exit
outputFile_error:
	li $v0, 4
	la $a0, outputFile_error_msg
	syscall
	j exit
#exit	
exit:
    li $v0, 10
    syscall
