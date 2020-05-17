.data 
	inputFile: .asciiz "/home/gilson/Documents/Computer Organization/mips-project-CO-UTFPR/inputFiles/test.csv" 
	outputFile: .asciiz "/home/gilson/Documents/Computer Organization/mips-project-CO-UTFPR/outputFiles/test.csv"
	inputFile_error_msg: .asciiz "error on open input file"
	outputFile_error_msg: .asciiz "error on create output file"
	comma: .asciiz ","
	lineBreak: .asciiz "\n"
    	.word 0
    	buffer: .space 1024
    	.word 0
    	buffer_int: .space 1024
    	.word 0
    	buffer_float: .space 1024
.text
main:
	#$s0 = inputFile file descriptor
	#$s1 = outputFile file descriptor
	#
	#
	#
	
   	#open inputFile
    	li $v0, 13
    	la $a0, inputFile
    	add $a1, $zero, $zero	#$a1 = 0(read)
    	add $a2, $zero, $zero
    	syscall
    	add $s0, $v0, $zero
    	bltz $s0, inputFile_error
    	#open outputFile
    	li $v0, 13
    	la $a0 outputFile
    	addi $a1, $zero, 1	#$a1 = 1(write)
    	add $a2, $zero, $zero
    	syscall    	
    	add $s1, $v0, $zero
    	bltz $s1, outputFile_error
    	
 	#close files
	li $v0, 16
    	add $a0, $s0, $zero
    	syscall
    	add $a0, $s1, $zero
    	syscall
	j exit

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
	
	add $s0, $a0, $zero #$s0 = input file
	add $s1, $a1, $zero #$s1 = output file
	
	#this nested loop get one line and go to
	#the file, if a x equal the actual x is
	#find they are added for the mean
outer_loop:
	#get int(x)
	add $a0, $s0, $zero
	jal extract_int
	add $s0, $s0, $v1
	add $s4, $v0, $zero #extracted int
	
	#get flot(y)
	add $a0, $s0, $v0
	jal extract_float
	add $s0, $s0, $v1
	mtc1 $zero, $f20 #set $f20 to zero
	add.s $f20, $f20, $f0 #extracted float
	
	add $s3, $s0, $zero #$s3 = copy of $s1 int actual line

	mtc1 $zero, $f22
	add.s $f22, $f22, $f20
	li $s6, 1
inner_loop:
	add $a0, $s3, $zero
	jal extract_int
	add $s3, $s3, $v1
	add $s5, $v0, $zero #extracted int
	
	beq $s3, 0, end_inner_loop #while(!end_of_file)
	
	add $a0, $s3, $v0
	jal extract_float
	add $s3, $s3, $v1
	mtc1 $zero, $f21
	add.s $f21, $f21, $f0 #extracted float
	
	bne $s4, $s5, x_else #verify if another x equal the actual x is find
	add.s $f22, $f21, $f20 #if is find, add y to $f22
	addi $s6, $s6, 1 #and increment the counter
	x_else:
	j inner_loop
end_inner_loop:
	bgt $s6, 1, div_else
	mtc1 $s6, $f23
	div.s $f22, $f22, $f23 
	div_else:
	#print x($s4) and y($f22)
	j outer_loop
end_outer_loop:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	add $sp, $sp, 12
	jr $ra
#----------------------------------------------
#extract int
#$a0 = input file
#$v0 = int extracted
#$v1 = number of chars readed
#----------------------------------------------
extract_int:	
	add $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $v0, 14
    	add $a0, $s0, $zero
    	la $a1, buffer
    	li $a2, 1
    	syscall	

	lw $ra, 0($sp)
	add $sp, $sp, 4
	
#----------------------------------------------
#extract float
#$a0
#$v0
#$v1
#----------------------------------------------
extract_float:

#----------------------------------------------
#print on output file
#$a0
#$v0
#$v1
#----------------------------------------------
print_on_file:

#----------------------------------------------
#atoi function
#$a0 = address of string
#$v0 = integer 
#----------------------------------------------
atoi:
	add $sp, $sp, -4
	sw $ra, 0($sp)
	#string address
	move $t0, $a0
	
	li $v0, 0
loop_1:
	lb $t1, 0($t0)
	
end_loop_1:


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
