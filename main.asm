.data 
	file: .asciiz "/home/gilson/Documents/test.csv" 
    	.word 0
    	buffer: .space 1024
.text
main:
   	 #open file
    	li $v0, 13
    	la $a0, file
    	add $a1, $zero, $zero
    	add $a2, $zero, $zero
    	syscall
    	add $s0, $v0, $zero
    	#read 4 bytes from file
    	li $v0, 14
    	add $a0, $s0, $zero
    	la $a1, buffer
    	li $a2, 1
    	syscall
    	#print
    	li $v0, 4
    	la $a0, buffer
    	syscall
    	
    	add $s0, $s0, -1
    	
    	#read 4 bytes from file
    	li $v0, 14
    	add $a0, $s0, $zero
    	la $a1, buffer
    	li $a2, 1
    	syscall
    	#print
    	li $v0, 4
    	la $a0, buffer
    	syscall
    	
 	#close file
	li $v0, 16
    	add $a0, $s0, $zero
    	syscall
	j exit

#----------------------------------------------
#
#
#
#----------------------------------------------

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


#exit	
exit:
    li $v0, 10
    syscall
