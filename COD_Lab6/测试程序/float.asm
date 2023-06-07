# Author: 2023_COD_TA
# Last_edit: 20230602
# ===================================== Floating-point instruction test program =====================================
# There are 4 tests in total, and only passing all of them can be considered correct. 
#
# Registers x25, x26 are the indication registers. 
# If the program runs correctly, it will eventually enter a win loop, and x25 will be 0x1; 
# If the program runs incorrectly, it will eventually enter a failure loop, with 0xf stored in x25.
# x26 indicating the test number where the error occurred.
#
# If you pass all the tests on FPGAOL, the LED[0] will light up as before.
#
# !!!!!!!!!!!!!!!! Please do not modify the code of this test program without permission !!!!!!!!!!!!!!!!!!!!!!!
# ==============================================================================================================


start:
	addi x26, x0, 0


test_1:
# Floating-point simple test
	addi x26, x26, 1
	addi a0, x0, 2
	fcvt.s.w fa0, a0, rne
	add a0, a0, a0
	add a0, a0, a0
	add a0, a0, a0
	fcvt.w.s a0, fa0, rne
	addi s0, x0, 2
	bne a0, s0, fail
	
	addi a0, x0, -2
	fcvt.s.w fa0, a0, rne
	add a0, a0, a0
	add a0, a0, a0
	add a0, a0, a0
	fcvt.w.s a0, fa0, rne
	addi s0, x0, -2
	bne a0, s0, fail


test_2:
# Floating-point rounding mode test
	addi x26, x26, 1
	li a0, 0x87654321
	fcvt.s.w fa0, a0, rne	
	fcvt.w.s a1, fa0, rne
	add x0, a0, a1		# useless!
	fcvt.s.w fa1, a0, rtz
	fcvt.w.s a2, fa1, rtz	
	add x0, a2, a2 		# useless!
	li a0, 0x76543210
	fcvt.s.w fa2, a0, rdn
	fcvt.w.s a3, fa2, rdn
	fcvt.s.w fa3, a0, rup
	fcvt.w.s a4, fa3, rup
	add x0, a3, a4		# useless!
	
	li s1, 0x87654300
	bne a1, s1, fail
	li s2, 0x87654380
	bne a2, s2, fail
	li s3, 0x76543200
	bne a3, s3, fail
	li s4, 0x76543280
	bne a4, s4, fail
	

test_3:
# Floating-point addition and subtraction test
	addi x26, x26, 1
	addi a0, x0, 1
	addi a1, x0, -2
	fcvt.s.w fa0, a0, rne
	fcvt.s.w fa1, a1, rne
	fadd.s fa2, fa0, fa1
	fcvt.w.s a2, fa2
	addi a3, x0, -1
	bne a2, a3, fail
	fcvt.s.w fa3, x0, rne
	fsub.s fa4, fa3, fa0
	fcvt.w.s a4, fa4, rne
	bne a2, a4, fail
	

test_4:
# FINAL test
 	addi x26, x26, 1
	addi t0, x0, 10
	
	addi a0, x0, 1
	addi a1, x0, 1
	addi t1, t0, -2
	fcvt.s.w fa0, a0, rne
	fcvt.s.w fa1, a1, rne
	fcvt.s.w fa3, x0, rne
	
loop_start:
	fadd.s fa2, fa1, fa0
	fadd.s fa0, fa1, fa3
	fadd.s fa1, fa2, fa3
	addi t1, t1, -1
	bne t1, x0, loop_start
	
loop_end:
	fcvt.w.s a2, fa2, rne
	li a3, 0x37
	bne a2, a3, fail
	jal win
	

fail:
	addi x25, x0, 0xf
	lui x27 7
	addi x27, x27, 0x700
	addi x27, x27, 0x700
	addi x27, x27, 0x100	# x27 = 7f00
	addi x28, x0, 1
	sw x28, 16(x27)		    # led[1] = 1
	beq x0, x0, fail	
    

win:
    addi x25, x0, 0x1
    addi x26, x0, 0
	lui x27 7
	addi x27, x27, 0x700
	addi x27, x27, 0x700
	addi x27, x27, 0x100	# x27 = 7f00
	addi x28, x0, 1
	sw x28 12(x27)		    # led[0] = 1
	beq x0, x0, win



