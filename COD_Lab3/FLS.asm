INPUT:	lb a5, 0x00007f00
	beq a5, x0, INPUT	#轮询
	lw a0, 0x00007f04
	addi a0, a0, -10	#判断是否为回车
	beq a0, x0, FLS
	addi a0, a0, -38	#求出对应数字
	addi t0, a0, 0
	add t0, t0, a6		#将上一个输入值的10倍与当前输入值相加
	slli a6, t0, 3
	add a6, a6, t0
	add a6, a6, t0		#记录当前输入值的10倍
	jal x0, INPUT
FLS:	addi t2, x0, 1	#置初值
	addi t4, x0, 1		#置初值
	li a4, 0x00000000	#存储地址
LOOP:	beq t0, x0, EXIT
	addi t0, t0, -1
	sw t1, (a4)
	sw t2, 4(a4)
	addi a1, x0, 8		#输出8次，每次1位
	addi a2, x0, 0
OUTPUT:	lb a5, 0x00007f08
	beq a5, x0, OUTPUT	#轮询
	sll a6, t2, a2		#左移a2位
	srli a6, a6, 28		#右移(7*4)位，取出对应位
	addi a2, a2, 4
	addi a1, a1, -1
	beq a6, x0, OUTPUT
	bne a6, x0, NOTZERO
LOOP2:	lb a5, 0x00007f08
	beq a5, x0, OUTPUT	#轮询
	sll a6, t2, a2		#左移a2位
	srli a6, a6, 28		#右移(7*4)位，取出对应位
	addi a2, a2, 4		#若放在NOTZERO之后，会导致a2+=4;和a1-=1;被执行9次
	addi a1, a1, -1
NOTZERO:	addi a3, x0, 58		#提供对比，区分0-9和a-f
	addi a6, a6, 48		#将0-9转换为对应ascii码
	blt a6, a3, NEXT
	addi a6, a6, 7		#将a-f转换为对应ascii码
NEXT:	sw a6, 0x00007f0c, a0
	bne a1, x0, LOOP2
	addi a6, x0, 10
ENDL:	lb a5, 0x00007f08
	beq a5, x0, ENDL
	sw a6, 0x00007f0c, a0	#a6=10，即换行符
	addi a4, a4, 8
	add t6, t2, t4
	add a7, x0, t6
	sltu a7, a7, t2		#若进位，a7=1，否则a7=0
	add t5, t1, t3
	add t5, t5, a7		#若进位则加1
	add t1, x0, t3
	add t2, x0, t4
	add t3, x0, t5
	add t4, x0, t6
	blt x0, t0, LOOP
EXIT:	nop
