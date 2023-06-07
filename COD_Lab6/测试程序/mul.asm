# Author: 2023_COD_TA
# Last_edit: 20230602
# ===================================== Multiply instruction test program ======================================
# There are 5 tests in total, and only passing all of them can be considered correct. 
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
# Continuous mul instruction correctness testing
    addi x26, x26, 1
    li a0, 0x12345678
    li a1, 0x87654321
    mul a2, a0, a1
    mul a3, a0, a2
    li a4, 0x70b88d78
    li a5, 0x0268a040
    bne a2, a4, fail
    bne a3, a5, fail


test_2:
# Correlation and jump after mul instruction
    addi x26, x26, 1
    auipc a0, 0
    li a1, 1
    mul a2, a0, a1
    jalr x0, 20(a2)
    j fail


test_3:
# Signed number multiplication test
    addi x26, x26, 1
    li a0, 0x12345678
    li a1, 0x87654321
    mulh a2, a0, a1
    mulh a3, a0, a2
    li a4, 0xf76c768d
    li a5, 0xff63df78
    bne a2, a4, fail
    bne a3, a5, fail


test_4:
# Unsigned number multiplication test
    addi x26, x26, 1
    li a0, 0x12345678
    li a1, 0x87654321
    mulhu a2, a0, a1
    mulh  a3, a2, a1
    li a4, 0x09A0CD05
    li a5, 0xFB76CE0F
    bne a2, a4, fail
    bne a3, a5, fail


test_5:
# Final test
    addi x26, x26, 1
    li a0, 0xabcd1234
    li a1, 0x87654321
    mulhsu a2, a0, a1
    mulhsu a3, a2, a1
    li a4, 0xD377D66D
    li a5, 0xE87294AD
    bne a2, a4, fail
    bne a3, a5, fail
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