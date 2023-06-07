# Author: 2023_COD_TA
# Last_edit: 20230526
#
# ================================ Branch Prediction Testcase:  Matrix Multiplication ================================
# ---- MEMORY Input ----
# 	0x0000 stores the size of A
# 	0x0004 stores the row size of A
# 	0x0008 stores the column size of A 
# 	0x000c stores the size of B
# 	0x0010 stores the row size of B
# 	0x0014 stores the column size of B 
# 	From 0x0018 to 0x0018 + 4*(size_A-1) stores the matrix A, Row major
# 	From 0x0018 + 4*size_A to 0x0018 + 4*size_A + 4*(size_B-1) stores the matrix B, Row major
#
# ---- MEMORY Output ----
# 	From 0x0018 + 4*(size_A+size_B) to 0x0018 + 4*(size_A+size_B) + 4*(size_C-1) stores the Answer, Row major
# Note: size_C = R_A * C_B
#
# Tips: You can set your own matrices for test
# 
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! DO NOT modify the code of the testcase !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# ====================================================================================================================

.data
4 # size of A
2 # Row size of A
2 # Column size of A 
6 # size of B
2 # Row size of B
3 # Column size of B 

# A
1
2
3
4

# B
-1
-1
-1
1
1
1


.text
# First we calculate some useful constants
# Shape of A
lw s0, 4(x0) # R_A
lw s1, 8(x0) # C_A
# Shape of B
lw a0, 16(x0) # R_B
lw a1, 20(x0) # C_B

# a2 stores base address of A
addi a2, x0, 0x18 
# a3 stores base address of B
lw a3, 0(x0)	# size of A
add a3, a3, a3
add a3, a3, a3	# a3 *= 4
add a3, a3, a2	
# a4 stores base address of C
lw a4, 12(x0)	# size of B
add a4, a4, a4
add a4, a4, a4  # a4 *= 4
add a4, a4, a3 
 
# ========================================
# 	Matrix Multiplication
# ========================================
Matrix_mul:
# for i in range(0, R_A)
addi s2, x0, 0
Matrix_loop1:

# for j in range(0, C_B)
	addi s3, x0, 0
	Matrix_loop2:
	addi s6, x0, 0	# s6 = C[i][j], initial 0
	
	# for k in range(0, C_A)
		addi s4, x0, 0
		Matrix_loop3:

		# C[i][j] += A[i][k] * B[k][j]
		add t3, s2, x0
		add t4, s1, x0
		jal Mul_init
		add s8, t5, x0	# s8 = i*C_A
		add s8, s8, s4	# s8 = i*C_A + k
		
		add s8, s8, s8
		add s8, s8, s8	
		add s8, a2, s8	# s8 <- base_A + (i*C_A + k) * 4
		lw s8, 0(s8)	# s8 <- A[i][k]
		
		add t3, s4, x0
		add t4, a1, x0
		jal Mul_init
		add s9, t5, x0	# s9 = k*C_B
		add s9, s9, s3  # s9 = k*C_B + j
		
		add s9, s9, s9
		add s9, s9, s9
		add s9, a3, s9	# s9 <- base_B + (k*C_B + j) * 4
		lw s9, 0(s9)	# s9 <- B[k][j]
		
		add t3, s8, x0
		add t4, s9, x0
		jal Mul_init
		add s6, t5, s6	# C[i][j] += A[i][k] * B[k][j]
		
		addi s4, s4, 1
		blt s4, s1, Matrix_loop3
		# END of loop3
	
	# Save C[i][j]
	add t3, s2, x0
	add t4, a1, x0
	jal Mul_init
	add s10, t5, x0		# s10 = i*C_B
	add s10 s3, s10		# s10 = i*C_B + j
	
	add s10, s10, s10
	add s10, s10, s10
	add s10, a4, s10	# s10 <- base_C + (i*C_B + j)*4
	sw s6, 0(s10)		# save C[i][j]
	
	addi s3, s3, 1
	blt s3, a1, Matrix_loop2
	# END of loop2

addi s2, s2, 1
blt s2, s0, Matrix_loop1
# END of loop1

ebreak
beq x0, x0, END
# END of Matrix Mul


# ========================================
# 	Multiplication function
# 	Calculate t3 * t4, store the answer in t5
# 	Used registers: t3, t4, t5, t6
# ========================================
Mul_init:
	addi t5, x0, 0
	addi t6, x0, 0
# We need to make t4 > 0
	blt x0, t4, Mul_start
	blt t3, x0, Mul_make_pos
	# t3 > 0 and t4 < 0, SWAP
	add t6, t3, t0
	add t3, t4, t0
	add t4, t6, t0
	beq x0, x0, Mul_start
Mul_make_pos:	 	
	# t3 < 0 and t4 < 0, make postive
	Mul_make_pos_1:
		addi t5, t5, 1
		addi t3, t3, 1
		blt t3, x0, Mul_make_pos_1
	Mul_make_pos_2:
		addi t6, t6, 1
		addi t4, t4, 1
		blt t4, x0, Mul_make_pos_2
	add t3, t5, x0
	add t4, t6, x0
	addi t5, x0, 0
	
Mul_start:
	add t5, t3, t5
	addi t4, t4, -1
	blt x0, t4, Mul_start
Mul_end:
	ret
# END of Multiply function
	
# =========== END ===========
END:
	beq x0, x0, END
	
