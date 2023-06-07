.globl _start
.text
    # assume text segment start at 0x00003000

_start:                                                              # 0x3000
    # ensure beq is OK
    beq x0, x0, START_TEST          # start
    nop
    nop

FAIL:                                                               # 0x300c
    lui x7, 8		# x7 = 0x08000
    addi x7, x7, -0x100	# x7 = 0x7f00
    addi x8, x0, 1
    sw x8, 16(x7)	# led[1] = 1
    beq x0, x0, FAIL	# loop

START_TEST:
    # every test 8-word aligned

    TEST_ADDI:                                                      # 0x3020
        addi a0, x0, 0x1            # a0 = 0x1
        addi t0, x0, 0x1            # t0 = 0x1
        beq t0, x0, FAIL            # t0 == x0, fail
        addi t1, x0, 0x10           # t1 = 0x10
        addi t0, t0, 0xF            # t0 = 0x10
        beq t0, t1, TEST_LUI        # t0 == t1, pass
        beq x0, x0, FAIL            # else, fail
        nop

    TEST_LUI:                                                       # 0x33040
        addi a0, a0, 0x1            # a0 = 0x2
        addi t0, x0, 0              # t0 = 0 (clear)
        addi t1, t1, 0x7f8          # t1 = 0x808
        lui t0, 0x1                 # t0 = 0x1000
        addi t1, t1, 0x7f8          # t1 = 0x1000
        beq t0, x0, FAIL            # t0 == x0, fail
        beq t0, t1, TEST_AUIPC      # t0 == t1, pass
        beq x0, x0, FAIL            # else, fail

    TEST_AUIPC:                                                     # 0x3060
        addi a0, a0, 0x1            # a0 = 0x3
        addi t0, x0, 0              # t0 = 0 (clear)
        lui t1, 0x3                 # t1 = 0x3000
        addi t1, t1, 0x70           # t1 = 0x3070
        auipc t0, 0x0               # t0 = 0x3070
        beq t0, t1, TEST_BEQ        # t0 == t1, pass
        beq x0, x0, FAIL            # else, fail
        nop

    TEST_BEQ:                                                       # 0x3080
        addi a0, a0, 0x1            # a0 = 0x4
        addi t0, t0, 0x1            # t0 = 0x3071
        beq t0, t1, FAIL            # t0 == t1, fail
        beq t1, t0, FAIL            # t1 == t0, fail
        addi t1, t1, 0x1            # t1 = 0x3071
        beq t0, t1, TEST_BNE        # t0 == t1, pass
        beq x0, x0, FAIL            # else, fail
        nop

    TEST_BNE:                                                       # 0x30A0
        addi a0, a0, 0x1            # a0 = 0x5
        bne t0, t1, FAIL            # t0 != t1, fail
        bne t1, t0, FAIL            # t1 != t0, fail
        addi t1, t1, 0x1            # t1 = 0x3072
        bne t0, t1, TEST_BLT        # t0 != r1, pass
        beq x0, x0, FAIL            # else, fail
        nop
        nop

    TEST_BLT:                                                       # 0x30C0
        addi a0, a0, 0x1            # a0 = 0x6
        lui t0, 0xFFFFF             # t0 = 0xFFFFF000
        blt t1, t0, FAIL            # t1 < t0, fail
        addi t0, x0, 0x1            # t0 = 0x1
        blt t1, t0, FAIL            # t1 < t0, fail
        lui t0, 0xFFFFF             # t0 = 0xFFFFF000
        blt t0, t1, TEST_BGE        # t0 < t1, pass
        beq x0, x0, FAIL            # else, fail

    TEST_BGE:                                                       # 0x30E0
        addi a0, a0, 0x1            # a0 = 0x7
        bge t0, t1, FAIL            # t0 > t1, fail
        addi t0, x0, 0x1            # t0 = 0x1
        bge t0, t1, FAIL            # t0 > t1, fail
        lui t0, 0x3                 # t0 = 0x3000
        addi t0, t0, 0x72           # t0 = 0x3072
        bge t0, t1, TEST_BLTU       # t0 >= t1, pass
        beq x0, x0, FAIL            # else, fail

    TEST_BLTU:                                                      # 0x3100
        addi a0, a0, 0x1            # a0 = 0x8
        bltu t0, t1, FAIL           # t0 < t1, fail
        lui t0, 0xFFFFF             # t0 = 0xFFFFF000
        bltu t0, t1, FAIL           # t0 < t1, fail
        bltu t1, t0, TEST_BGEU      # t1 < t0, pass
        beq x0, x0, FAIL
        nop
        nop

    TEST_BGEU:                                                      # 0x3120
        addi a0, a0, 0x1            # a0 = 0x9
        bgeu t1, t0, FAIL           # t1 >= t0, fail
        addi t0, x0, 1              # t0 = 1
        bgeu t0, t1, FAIL           # t0 >= t1, fail
        bgeu t1, t0, TEST_JAL       # t1 >= t0, pass
        beq x0, x0, FAIL            # else, fail
        nop
        nop

    TEST_JAL:                                                       # 0x3140
        addi a0, a0, 0x1            # a0 = 0xA
        jal t0, FLAG                # t0 = 0x3148
        beq x0, x0, FAIL            # not jump, fail
    FLAG:                           # jump flag
    	lui t1, 0x3		    # t1 = 0x3000
        addi t1, t1, 0x148          # t1 = 0x3148
        beq t0, t1, TEST_JALR       # t0 == t1, pass
        beq x0, x0, FAIL            # else, fail
        nop

    TEST_JALR:                                                      # 0x3160
        addi a0, a0, 0x1            # a0 = 0xB
        auipc t0, 0x0               # t0 = 0x3164
        jalr t1, t0, 0xC            # t1 = 0x316C
        beq x0, x0, FAIL            # not jump, fail
        addi t0, t0, 0x08          # t0 = 0x316C
        beq t0, t1, TEST_ANDI       # t0 == t1, pass
        beq x0, x0, FAIL            # else, fail
        nop

    TEST_ANDI:                                                      # 0x3180
        addi a0, a0, 0x1            # a0 = 0xC
        addi t0, x0, 0xFFFFFFFF     # t0 = 0xFFFFFFFF
        andi t0, t0, 0x5FC          # t0 = 0x000005FC
        addi t1, x0, 0              # t1 = 0x0
        addi t1, t1, 0x5FC          # t1 = 0x000005FC
        bne t0, t1, FAIL            # t0 != t1, fail
        jal x0, TEST_ORI            # else, pass
        nop

    TEST_ORI:                                                       # 0x31A0
        addi a0, a0, 0x1            # a0 = 0xD
        ori t0, t0, 0x306           # t0 = 0xFFFFF7FE
        addi t1, t1, 0x202          # t1 = 0xFFFFF7FE
        bne t0, t1, FAIL            # t0 != t1, fail
        jal x0, TEST_XORI           # else, pass
        nop
        nop
        nop

    TEST_XORI:                                                      # 0x31C0
        addi a0, a0, 0x1            # a0 = 0xE
        xori t0, t0, 0x3AF          # t0 = 0xFFFFF451
        addi t1, t1, 0xFFFFFC53     # t1 = 0xFFFFF451
        bne t0, t1, FAIL            # t0 != t1, fail
        jal x0, TEST_SLTI           # else, pass
        nop
        nop
        nop

    TEST_SLTI:                                                      # 0x31E0
        addi a0, a0, 0x1            # a0 = 0xF
        slti t0, t1, 0x452          # t0 = t1 < 1
        addi t2, x0, 0x1            # t2 = 1
        bne t0, t2, FAIL            # t0 != t2, fail
        slti t0, t0, 0x1            # t0 = t0 < 1
        bne t0, x0, FAIL            # t0 != 0, fail
        jal x0, TEST_SLTIU          # else, pass
        nop

    TEST_SLTIU:                                                     # 0x3200
        addi a0, a0, 0x1            # a0 = 0x10
        sltiu t0, t1, 0x1           # t0 = t1 < 1
        bne t0, x0, FAIL            # t0 != 0, fail
        sltiu t0, t0, 0x2           # t0 = t0 < 2
        bne t0, t2, FAIL            # t0 != t2, fail
        jal x0, TEST_SLLI           # else, pass
        nop
        nop

    TEST_SLLI:                                                      # 0x3220
        addi a0, a0, 0x1            # a0 = 0x11
        lui t0, 0x12345             # t0 = 0x12345000
        addi t0, t0, 0x678          # t0 = 0x12345678
        slli t0, t0, 12             # t0 = 0x45678000
        lui t1, 0x45678             # t1 = 0x45678000
        bne t0, t1, FAIL            # t0 != t1, fail
        jal x0, TEST_SRLI           # else, pass
        nop

    TEST_SRLI:                                                      # 0x3240
        addi a0, a0, 0x1            # a0 = 0x12
        lui t0, 0xFEDCB             # t0 = 0xFEDCB000
        srli t0, t0, 12             # t0 = 0x000FEDCB
        lui t1, 0xFF                # t1 = 0x000FF000
        addi t1, t1, 0xFFFFFDCB     # t1 = 0x000FEDCB
        bne t0, t1, FAIL            # t0 != t1, fail
        jal x0, TEST_SRAI           # else, pass
        nop

    TEST_SRAI:                                                      # 0x3260
        addi a0, a0, 0x1            # a0 = 0x13
        lui t0, 0xFEDCB             # t0 = 0xFEDCB000
        srai t0, t0, 12             # t0 = 0xFFFFEDCB
        lui t1, 0xFFFFF             # t1 = 0xFFFFF000
        addi t1, t1, 0xFFFFFDCB     # t1 = 0xFFFFEDCB
        bne t0, t1, FAIL            # t0 != t1, fail
        jal x0, TEST_ADD            # else, pass
        nop

    TEST_ADD:                                                       # 0x3280
        addi a0, a0, 0x1            # a0 = 0x14
        addi t0, x0, 0x2            # t0 = 0x2
        add t0, t0, t0              # t0 = 4
        add t1, x0, t0              # t1 = 4
        bne t0, t1, FAIL            # t0 != t1, fail
        jal x0, TEST_SUB            # else, pass
        nop
        nop

    TEST_SUB:                                                       # 0x32A0
        addi a0, a0, 0x1            # a0 = 0x15
        addi t0, t0, 0x1            # t0 = 5
        sub t0, t1, t0              # t0 = 0xFFFFFFFF
        addi t1, x0, 0xFFFFFFFF     # t1 = 0xFFFFFFFF
        bne t0, t1, FAIL            # t0 != t1, fail
        jal x0, TEST_AND            # else, pass
        nop
        nop

    TEST_AND:                                                       # 0x32C0
        addi a0, a0, 0x1            # a0 = 0x16
        addi t0, x0, 0xFFFFFCFC     # t0 = 0xFFFFFCFC
        lui t1, 0xC3C3C             # t1 = 0xC3C3C000
        addi t1, t1, 0x3C3          # t1 = 0xC3C3C3C3
        and t2, t0, t1              # t2 = 0xC3C3C0C0
        lui t3, 0xC3C3C             # t3 = 0xC3C3C000
        addi t3, t3, 0x0C0          # t3 = 0xC3C3C0C0
        bne t2, t3, FAIL            # t2 != t3, fail

    TEST_OR:                                                        # 0x32E0
        addi a0, a0, 0x1            # a0 = 0x17
        or t2, t0, t1               # t2 = 0xFFFFFFFF
        addi t3, x0, 0xFFFFFFFF     # t3 = 0xFFFFFFFF
        bne t2, t3, FAIL            # t2 != t3, fail
        jal x0, TEST_XOR            # else, pass
        nop
        nop
        nop

    TEST_XOR:                                                       # 0x3300
        addi a0, a0, 0x1            # a0 = 0x18
        xor t2, t0, t1              # t2 = 0x3C3C3F3F
        lui t3, 0x3C3C4             # t3 = 0x3C3C4000
        addi t3, t3, 0xFFFFFF3F     # t3 = 0x3C3C3F3F
        bne t2, t3, FAIL            # t2 != t3, fail
        jal x0, TEST_SLT            # else, pass
        nop
        nop

    TEST_SLT:                                                       # 0x3320
        addi a0, a0, 0x1            # a0 = 0x19
        addi t1, x0, 0x1            # t1 = 0x1
        slt t2, t0, t1              # t2 = t0 < t1
        bne t2, t1, FAIL            # t2 != t1, fail
        slt t2, t1, t0              # t2 = t1 < t0
        bne t2, x0, FAIL            # t2 != 0x0, fail
        jal TEST_SLTU               # else, pass
        nop

    TEST_SLTU:                                                      # 0x3340
        addi a0, a0, 0x1            # a0 = 0x1A
        addi t1, x0, 0x1            # t1 = 0x1
        sltu t2, t0, t1             # t2 = t0 < t1
        bne t2, x0, FAIL            # t2 != 0x0, fail
        sltu t2, t1, t0             # t2 = t1 < t0
        bne t2, t1, FAIL            # t2 != t1, fail
        jal x0, TEST_SLL            # else, pass
        nop

    TEST_SLL:                                                       # 0x3360
        addi a0, a0, 0x1            # a0 = 0x1B
        addi t1, x0, 16             # t1 = 16
        sll t2, t0, t1              # t2 = 0xFCFC0000
        lui t3, 0xFCFC0             # t3 = 0xFCFC0000
        bne t2, t3, FAIL            # t2 != t3, fail
        jal x0, TEST_SRL            # else, pass
        nop
        nop

    TEST_SRL:                                                       # 0x3380
        addi a0, a0, 0x1            # a0 = 0x1C
        srl t2, t0, t1              # t2 = 0x0000FFFF
        lui t3, 0x10                # t3 = 0x10000
        addi t3, t3, 0xFFFFFFFF     # t3 = 0x0000FFFF
        bne t2, t3, FAIL            # t2 != t3, fail
        jal x0, TEST_SRA            # else, pass
        nop
        nop

    TEST_SRA:                                                       # 0x33A0
        addi a0, a0, 0x1            # a0 = 0x1D
        sra t2, t0, t1              # t2 = 0xFFFFFFFF
        addi t3, x0, 0xFFFFFFFF     # t3 = 0xFFFFFFFF
        bne t2, t3, FAIL            # t2 != t3, fail
        jal x0, TEST_SB             # else, pass
        nop
        nop
        nop

    # assume data memory at 0x0000
    TEST_SB:                                                        # 0x33C0
        addi a0, a0, 0x1            # a0 = 0x1E
        addi t0, x0, 0x3FC          # t0 = 0x3FC
        addi t1, x0, 0x1            # t1 = 0x1
        sb t0, 0(t1)                # (0x2001) = 0xFC
        jal x0, TEST_LB             # go to TEST_LB
        nop
        nop
        nop

    TEST_LB:                                                        # 0x33E0
        addi a0, a0, 0x1            # a0 = 0x1F
        addi t0, x0, 0xFFFFFFFC     # t0 = 0xFFFFFFFC
        lb t2, 0(t1)                # t2 = 0xFFFFFFFC
        bne t0, t2, FAIL            # t0 != t2, fail
        jal x0, TEST_LBU            # else, pass
        nop
        nop
        nop

    TEST_LBU:                                                       # 0x3400
        addi a0, a0, 0x1            # a0 = 0x20
        addi t0, t0, 0x100          # t0 = 0xFC
        lbu t2, 0(t1)               # t2 = 0xFC
        bne t0, t2, FAIL            # t0 != t2, fail
        jal x0, TEST_SH             # else, pass
        nop
        nop
        nop

    TEST_SH:                                                        # 0x3420
        addi a0, a0, 0x1            # a0 = 0x21
        addi t0, t0, 0xFFFFFF01     # t0 = 0xFFFFFFFD
        addi t1, t1, 1              # t1 = 0x2
        sh t0, 0(t1)                # (0x2002) = 0xFFFD
        jal x0, TEST_LH             # go to TEST_LH
        nop
        nop
        nop

    TEST_LH:                                                        # 0x3440
        addi a0, a0, 0x1            # a0 = 0x22
        lh t2, 0(t1)                # t2 = 0xFFFFFFFD
        bne t0, t2, FAIL            # t0 != t2, fail
        jal x0, TEST_LHU            # else, pass
        nop
        nop
        nop
        nop

    TEST_LHU:                                                       # 0x3460
        addi a0, a0, 0x1            # a0 = 0x23
        lhu t2, 0(t1)               # t2 = 0xFFFD
        lui t0, 0x10                # t0 = 0x10000
        addi t0, t0, 0xFFFFFFFD     # t0 = 0xFFFD
        bne t0, t2, FAIL            # t0 != t2, fail
        jal x0, TEST_SW             # else, pass
        nop
        nop

    TEST_SW:                                                        # 0x3480
        addi a0, a0, 0x1            # a0 = 0x24
        addi t1, t1, 0x2            # t1 = 0x4
        addi t0, x0, 0xFFFFFFFE     # t0 = 0xFFFFFFFE
        sw t0, 0(t1)                # (0x2004) = 0xFFFFFFFE
        jal x0, TEST_LW             # go to TEST LW
        nop
        nop
        nop

    TEST_LW:                                                        # 0x34A0
        addi a0, a0, 0x1            # a0 = 0x25
        lw t2, 0(t1)                # t2 = 0xFFFFFFFE
        bne t2, t0, FAIL            # t2 != t0, fail
        jal x0, WIN          # else, pass
        nop
        nop
        nop
        nop

WIN:                                                                # 0x34C0
    # pc larger than 0x34D0 means beq not working, which indicates all tests failed
    # loop here means all tests passed
    lui x7, 8		# x7 = 0x08000
    addi x7, x7, -0x100	# x7 = 0x7f00
    addi x8, x0, 1
    sw x8, 12(x7)	# led[0] = 1
    beq x0, x0, WIN	# loop
