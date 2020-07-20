.data
	inputFile: .asciiz "/home/gilson/Documents/Computer Organization/mips-project-CO-UTFPR/inputFiles/test.csv" 
	num: .asciiz "10,12.1"
	null: .asciiz ""
	buffer_input: .space 1024
	teste: .float 8.77
.text
	#mfhi = remainder mflo = quotient
int2strig:
	li $t3, 0
	move $s0, $a0
	move $s1, $a1
	
	li $t4, 10
	div $s1, $t4
	mfhi $t4
	beqz $t4 int2string_continue
	move $a1, $t4
	move $a0, $s0
	jal int2string
	move $t3, $v0
int2string_continue:
	li $t4, 10
	div $s1, $t4
	add $t3

	