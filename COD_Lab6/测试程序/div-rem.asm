# Author: 2023_COD_TA
# Last_edit: 20230602
# ===================================== Division and remainder test program =====================================
# There are 3 tests in total, and only passing all of them can be considered correct. 
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
    addi x26, x26, 1
    li a0, 0x12345678
    li a1, 0x87654321
    div a2, a1, a0
    divu a3, a1, a0
    li a4, 0xfffffffa
    li a5, 0x7
    bne a2, a4, fail
    bne a3, a5, fail


test_2:
    addi x26, x26, 1
    li a0, 0x12345678
    li a1, 0x87654321
    rem a2, a1, a0
    remu a3, a1, a0
    li a4, 0xf49f49f1
    li a5, 0x7f6e5d9
    bne a2, a4, fail
    bne a3, a5, fail


test_3:
    addi x26, x26, 1
    li a0, 0x36
    li a1, 0x25
    mul a2, a1, a0
    div a3, a2, a0
    bne a3, a1, fail
    div a4, a2, a1
    rem a4, a1, a0
    bne a4, a1, fail
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
