#---------------------------------------------------#
#Assembly code for CC53B-CC31(Computer Organization)
#Author: Gilson Junior Soares
#----------------------------------------------------#
.eqv buffer_input_length 1024
.data 
	inputFile_error_msg: .asciiz "error on open input file"
	outputFile_error_msg: .asciiz "error on create output file"
	invalid_x_input: .asciiz "invalid x value"
	comma: .asciiz ","
	quote: .byte 34
	null: .asciiz ""
	.word 0
	lineBreak: .byte 10
    	.word 0
    	buffer_input: .space 1024
    	.word 0
    	buffer: .space 100
    	.word 0
    	position: .space 4
.text
main:
	add $sp, $sp, -8
	sw $s1, 4($sp)
	sw $s2, 0($sp) 
	
	move $s1, $a0
	move $s2, $a1
main_loop:
	lw $a0, ($s2)
	lw $a1, 4($s2)
	#mean
	jal mean
	add $s2, $s2, 8
	sub $s1, $s1, 2
	bnez $s1, main_loop
	
	lw $s1, 4($sp)
	lw $s2, 0($sp)
	add $sp, $sp, 8
	j exit
#----------------------------------------------#
#mean function
#função que lê do arquivo os dados e realiza a 
#media
#----------------------------------------------#
#args:
#$a0 = input file
#$a1 = output file
#----------------------------------------------#
mean:
	add $sp, $sp, -32
	sw $s5, 28($sp)
	sw $s4, 24($sp)
	sw $ra, 20($sp)
	swc1 $f20, 16($sp)
	sw $s3, 12($sp)
	sw $s2, 8($sp)
	sw $s1, 4($sp)
	sw $s0, 0($sp)

	move $t0, $a0
	move $t1, $a1
	#open inputFile
	#input file descritor = $s0
    	li $v0, 13
    	move $a0, $t0
    	add $a1, $zero, $zero	#$a1 = 0(read)
    	add $a2, $zero, $zero
    	syscall
    	add $s0, $v0, $zero
    	bltz $s0, inputFile_error
    	
	#open output file	
	#input file descriptor = $s1
	li $v0, 13
	move $a0, $t1
	li $a1, 1
	add $a2, $zero, $zero
	syscall
	add $s1, $v0, $zero
	bltz $s1, outputFile_error
	
	#getting firts numbers
	#get int(x) and save in $s2
	move $a0, $s0
	jal extract_int
	add $s2, $v0, $zero #extracted int
	beq $v1, 1, extract_numbers_end_loop
	
	#get float(y)
	move $a0, $s0
	jal extract_float
	mtc1 $zero, $f20 #set $f20 to zero
	add.s $f20, $f20, $f0 #extracted float
	
	li $s5, 0
	#read numbers of file and add to array
extract_numbers_loop:
	addi $s5, $s5, 1
	#get int(x) and save in $s2
	move $a0, $s0
	jal extract_int
	add $s4, $v0, $zero #extracted int
	beq $v1, 1, extract_number_loop_not_equal
	bne $s4, $s2, extract_number_loop_not_equal
	#get float(y)
	move $a0, $s0
	jal extract_float
	add.s $f20, $f20, $f0 #extracted float
	j extract_numbers_loop
extract_number_loop_not_equal:
	
	#writing quotation
	move $a0, $s1
	jal write_quotation
	
	#writing int
	la $a0, buffer
	move $a1, $s2
	jal int2string
	
	la $a0, buffer
	jal length
	
	move $a2, $v0
	li $v0, 15
	move $a0, $s1
	la $a1, buffer
	syscall
	bltz $v0, exit

	#writing quotation
	move $a0, $s1
	jal write_quotation

	
	#write comma on file
	li $v0, 15
	move $a0, $s1
	la $a1, comma
	li $a2, 1
	syscall
	
	#writing quotation
	move $a0, $s1
	jal write_quotation

	#write float on file
	mov.s $f12, $f20
	#lw $t0, 8($s3)
	mtc1 $s5, $f4
	cvt.s.w $f4, $f4
	div.s $f12, $f12, $f4
	
	jal float2string
	
	la $a0, buffer
	jal length
	
	move $a2, $v0
	li $v0, 15
	move $a0, $s1
	la $a1, buffer
	syscall
	
	#writing quotation
	move $a0, $s1
	jal write_quotation
	
	#writing line break
	li $v0,15
	move $a0, $s1
	la $a1, lineBreak
	li $a2, 1
	syscall
	
	move $s2, $s4
	li $s5, 0
	mtc1 $zero, $f20
	cvt.s.w $f20, $f20
	
	#get float(y)
	move $a0, $s0
	jal extract_float
	bgtz $v1, extract_numbers_end_loop
	mtc1 $zero, $f20 #set $f20 to zero
	add.s $f20, $f20, $f0 #extracted float
	
	j extract_numbers_loop
extract_numbers_end_loop:

	#close files	
	li $v0, 16
	add $a0, $s0, $zero
	syscall
	add $a0, $s1, $zero
	syscall
	
	lw $s5, 28($sp)
	lw $s4, 24($sp)
	lw $ra, 20($sp)
	lwc1 $f20, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	add $sp, $sp, 32
	jr $ra
#----------------------------------------------#
#extract int
#função que extrai um numero inteiro do arquivo
#----------------------------------------------#
#args:
#$a0 = input file
#returns:
#$v0 = int extracted
#$v1 = end of file flag
#----------------------------------------------#
extract_int:	
	add $sp, $sp, -20
	sw $s3, 16($sp)
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)
	
	move $s0, $a0 #file descriptor
	
	li $s3, 0 #end of file flag
	la $t0, buffer_input
	la $t3, buffer
	
extract_int_quotation:

	#*to do: remove spaces
	li $v0, 14
    	add $a0, $s0, $zero
	la $a1, buffer_input
	li $a2, 1
	syscall
	beqz $v0, extract_int_end_of_file_flag
	
	lb $t2, ($t0)
	
	#quotation
	beq $t2, '"', extract_int_quotation
	
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
	j end_string_int_copy
	
end_string_int_file_descriptor_adjustment:

	lb $t2, null #load null terminator
	sb $t2, ($t3) #stores null to flag buffer_int end
	
	la $a0, buffer
	jal string_to_int
	move $v0, $v0 #return int

	j extract_int_exit

extract_int_end_of_file_flag:

	li $s3, 1 #end of file flag

extract_int_exit:

	move $v1, $s3
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	add $sp, $sp, 20
	jr $ra
#----------------------------------------------#
#extract float
#função que extrai um float do arquivo
#----------------------------------------------#
#args:
#$a0 = input file
#returns:
#$f0 = return float
#$v1 = end of file flag
#----------------------------------------------#
extract_float:

	add $sp, $sp, -20
	sw $s3, 16($sp)
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)
	
	move $s0, $a0 #file descriptor
	
	li $s3, 0 #end of file flag
	la $t0, buffer_input
	la $t3, buffer
	
extract_float_quotation:
	#*to do: remove spaces
	li $v0, 14
	add $a0, $s0, $zero
	la $a1, buffer_input
	li $a2, 1
	syscall
	beqz $v0, extract_float_end_of_file_flag
	
	lb $t2, ($t0)
	
	beq $t2, '"', extract_float_quotation
	
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
	beqz $v0, end_string_float_file_descriptor_adjustment_flag_end

	j end_string_float_copy	
	
end_string_float_file_descriptor_adjustment_flag_end:

	li $s3, 1

end_string_float_file_descriptor_adjustment:

	lb $t2, null
	sb $t2, ($t3)
	
	la $a0, buffer
	jal string_to_float
	mov.s $f0, $f0
	j end_string_float_file_exit

extract_float_end_of_file_flag:

	li $s3, 1

end_string_float_file_exit:

	move $v1, $s3
	
	lw $s3, 16($sp)
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	add $sp, $sp, 20
	jr $ra

#----------------------------------------------#
#string_to_int
#função que converte uma string para inteiro
#----------------------------------------------#
#args:
#$a0 = address of string
#returns:
#$v0 = integer 
#----------------------------------------------#
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
#----------------------------------------------#
#string_to_float function
#função que converter string para float
#----------------------------------------------#
#args:
#$a0 = address of string
#returns:
#$f0 = float 
#----------------------------------------------#
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
#----------------------------------------------#
#int2string:
#função para converter int para string
#----------------------------------------------#
#arguments:
#$a1 = int number 
#$a0 = string address
#returns:
#$v1 = address of string
#----------------------------------------------#
int2string:
	add $sp, $sp, -4
	sw $ra, ($sp)
	
	move $t0, $a0
	
	#negative number verification
	bgez $a1, int2string_negative_verification_continue
	mul $a1, $a1, -1
	li $t2, '-' #- signal
	sb $t2, ($t0)
	add $t0, $t0,1 
int2string_negative_verification_continue:

	move $a1, $a1
	move $a0, $t0
	jal int2string_recursive
	
	lw $ra, ($sp)
	add $sp, $sp, 4
	jr $ra
int2string_recursive:
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
	beqz $t4 int2string_recursive_continue #(if n/10 != 0)
	move $a1, $t4
	move $a0, $s0
	jal int2string_recursive #recursive call of int2string
	move $s2, $v0 #save return
int2string_recursive_continue:
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
	move $v1, $s0 #return string address

	lw $ra, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 16
	jr $ra
#----------------------------------------------#
#float2string
#função que converte de float para string
#----------------------------------------------#
#arguments:
#$f12 = float number 
#return:
#$v0 = address of string
#----------------------------------------------#
float2string:
	#f12 = float
	#$a0 = string
	add $sp, $sp, -28
	swc1 $f22, 24($sp)
	swc1 $f21, 20($sp)
	swc1 $f20, 16($sp)
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)
	
	la $s0, buffer
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
	
	#odd problem correction
	#li $t4, 10
	#div $s2, $t4
	#mfhi $t4 
	#bne $t4, 9, odd_correction_continue
	#add $s2, $s2, 1
	
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
	
	bgt $s2, 9, nine_correction
	li $t0, '0'
	sb $t0, ($s0)
	add $s0, $s0, 1
	
nine_correction:
	
	move $a0, $s0
	move $a1, $s2
	jal int2string
	move $s0, $v1
	
	la $v0, buffer
	
	lwc1 $f22, 24($sp)
	lwc1 $f21, 20($sp)
	lwc1 $f20, 16($sp)
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	add $sp, $sp, 28
	jr $ra
#----------------------------------------------#
#length:
#função que calcula o tamanho de uma string
#----------------------------------------------#
#args:
#$a0 = address of string
#returns:
#$v0 = size of string
#----------------------------------------------#
length:
	li $v0, 0
length_loop:
	lb $t0, ($a0)
	beqz $t0, length_loop_end
	add $a0, $a0, 1
	add $v0, $v0, 1
	j length_loop 
length_loop_end:
	jr $ra
#----------------------------------------------#
#length:
#função que calcula o tamanho de uma string
#----------------------------------------------#
#args:
#$a0 = file descriptor
#returns:
#----------------------------------------------#
write_quotation:
	li $v0, 15
	la $a1, quote
	li $a2, 1
	syscall
	
	jr $ra
#----------------------------------------------#
#error's labels
#----------------------------------------------#
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
#----------------------------------------------#
#exit label	
#----------------------------------------------#
exit:
    li $v0, 10
    syscall
