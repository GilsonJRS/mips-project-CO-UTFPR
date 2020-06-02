.data
	inputFile: .asciiz "/home/gilson/Documents/Computer Organization/mips-project-CO-UTFPR/inputFiles/test.csv" 
	num: .asciiz "10,12.1"
	null: .asciiz ""
	buffer_input: .space 1024
	
.text
	li $v0, 13
    	la $a0, inputFile
    	add $a1, $zero, $zero	#$a1 = 0(read)
    	add $a2, $zero, $zero
    	syscall
    	add $s0, $v0, $zero
    	add $s1, $s0, $zero
    	
    	li $v0, 14
    	add $a0, $s0, $zero
	la $a1, buffer_input
	li $a2, 1
	syscall
	
	la $a0, buffer_input
	li $v0, 4
	syscall
    	
    	li $v0, 14
    	add $a0, $s1, $zero
	la $a1, buffer_input
	li $a2, 1
	syscall

	la $a0, buffer_input
	li $v0, 4
	syscall