.text

init_student:
	# $a0 = int id
	# $a1 = int credits
	# $a2 = char *name
	# $a3 = struct student *record
	
	# transfer 22 bits of student id and store in $t0
	and $t0, $a0, $a0
	
	# shift the 22 bits of student id to the left most of $t0
	sll $t0, $t0, 10
	
	# transfer 10 bits of credits to $t0
	andi $a1, $a1, 0x3FF	# turn off all except bit of interest
	or $t0, $t0, $a1	# store id and credit in $t0
	
	# write bytes 0-3 to memory (id and credit)
	sw $t0, 0($a3)
	
	# write bytes 4-7 to memory (pointer to name)
	sw $a2, 4($a3)

	jr $ra
	
print_student:
	# $a0 = struct student *record
	
	# store bytes 0-3 in $t0 (id and credit)
	lw $t0, 0($a0)
	
	# extract credit's 10 bits to $t1
	andi $t1, $t0, 0x3FF
	
	# shift id's 22 bits over so $t0 only contains id
	srl $t0, $t0, 10 # $t0 now only stores id
	
	# store bytes 4-7 in $t2 (pointer to name)
	lw $t2, 4($a0)
	
	# print id
	li $v0, 1 # to print int
	move $a0, $t0
	syscall
	
	# print a space char
	li $v0, 11 # to print char
	li $a0, 32 # ascii for space
	syscall
	
	# print credit
	li $v0, 1 # to print int
	move $a0, $t1
	syscall
	
	# print a space char
	li $v0, 11 # to print char
	li $a0, 32 # ascii for space
	syscall
	
	# print name
	li $v0, 4 # to print string
	move $a0, $t2
	syscall

	jr $ra
	
init_student_array:
	jr $ra
	
insert:
	jr $ra
	
search:
	jr $ra

delete:
	jr $ra
