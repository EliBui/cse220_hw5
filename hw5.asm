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
	# $s0 = int num_students
	# $s1 = int id_list[]
	# $s2 = int credits_list[]
	# $s3 = char *name
	# $s4 = struct student records[]
	# $s5 = counter
	
	# save $ra before calling init_student
	addi $sp, $sp, -28 	# make space on stack for 7 registers
	sw $ra, 24($sp)		# save $ra on stack
	sw $s0, 20($sp)		# save $s0 on stack
	sw $s1, 16($sp)		# save $s1 on stack
	sw $s2, 12($sp)		# save $s2 on stack
	sw $s3, 8($sp)		# save $s3 on stack
	sw $s4, 4($sp)		# save $s4 on stack
	sw $s5, 0($sp)		# save $s5 on stack
	
	# transfer $a to $s
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	# get address of records and put it on $s4
	lw $s4, 28($sp) # records should be at the top of the stack
	
	# initialize a counter at $s5
	li $s5, 0
	
	beqz $s0, recordDone	# break if num_students == 0
	
	loopRecord:
		# calculate offset and store in $t0
		sll $t0, $s5, 2 	# $t0 = counter * 4
		
		# add offset to id and store id value in $a0
		add $t1, $s1, $t0
		lw $a0, 0($t1)
		
		# add offset to credits and store credits value in $a1
		add $t1, $s2, $t0
		lw $a1, 0($t1)
		
		# put address of the first letter of name in $a2
		move $a2, $s3
		
		# calculate offset for record and store in $t0
		sll $t0, $s5, 3 	# $t0 = counter * 8
		
		# put address of the record struct in $a3
		add $t1, $s4, $t0
		move $a3, $t1
		
		jal init_student	# call init_student
		#move $a0, $a3
		#jal print_student
		
		addi $s5, $s5, 1	# increment counter i++
		
		beq $s0, $s5, recordDone # break if num_students == counter
		
		# if not all students are initialized, then move on to next name
		loopName:
			lb $t1, 0($s3)
			beqz $t1, nameDone # exit loop if null
			addi $s3, $s3, 1 # next char
			j loopName
		nameDone:
		addi $s3, $s3, 1 	# skip \0
		j loopRecord
	recordDone:
	lw $s5, 0($sp)		# restore $s5 from stack
	lw $s4, 4($sp)		# restore $s4 from stack
	lw $s3, 8($sp)		# restore $s3 from stack
	lw $s2, 12($sp)		# restore $s2 from stack
	lw $s1, 16($sp)		# restore $s1 from stack
	lw $s0, 20($sp)		# restore $s0 from stack
	lw $ra, 24($sp) 	# restore $ra from stack
	addi $sp, $sp, 28	# deallocate stack space
	jr $ra
	
insert:
	# $a0 = struct student *record
	# $a1 = struct student *table[]
	# $a2 = int table_size
	
	# calculate index
	lw $t0, 0($a0)		# $t0 contains bytes 0-3 of record
	srl $t0, $t0, 10	# $t0 now contains only id
	div $t0, $a2		# divivde id by table size
	mfhi $t0		# get remainder (index) and store in $t0
	
	# calculate index offset
	sll $t0, $t0, 2		# multiply index by 4 to get offset 
	add $t1, $a1, $t0	# $t1 contains address of index to be inserted
	
	# calculate max address of table
	addi $t2, $a2, -1	# $t2 now has table size - 1
	sll $t2, $t2, 2		# multiply table size by 4 to get offset of last location
	add $t2, $t2, $a1	# $t2 contains address of last location
	
	# store starting address in $t3
	move $t3, $t1
	li $t5, -1 # load -1 into $t5
	
	while: #loops until empty spot is found or complete a full rotation
		lw $t4, 0($t1) 			# $t4 contains value of table location
		beqz $t4, insert_to_table	# empty spot found, insert to table 
		beq $t4, $t5 insert_to_table	# tombstone found, insert to table
		
		addi $t1, $t1, 4	# increment to the next table address
		ble $t1, $t2, skip 	# skip over the loop around if $t1 is not greater than max address
		
		# this code is reached if $t1 is greater than max address
		move $t1, $a1 		# move $t1 back to first address of table
		
		skip:
		beq $t1, $t3 no_space 	# no empty space found (we reached our starting address)
		j while
														
	insert_to_table:
		sw $a0, 0($t1) # write address of record to $t1
		
		# load the index to $v0
		sub $t1, $t1, $a1 	# subtract inserted address from address of first location
		srl $t1, $t1, 2		# divide by 2 to get index from offset
		move $v0, $t1
		j exit
	
	no_space:
		li $v0, -1 	# no space in table, return -1
	
	exit:
	jr $ra
	
search:
	jr $ra

delete:
	jr $ra
