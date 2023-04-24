# Lab3 Report

## 核心代码介绍

#### 用于计算斐波那契-卢卡斯数列的核心代码（包括处理大整数运算与存储的核心代码）

```assembly
INPUT:
	...//外设输入
FLS:	
	addi t2, x0, 1		#置F1初值
	addi t4, x0, 1		#置F2初值
	li a4, 0x00000000	#置存储地址初值
LOOP:	
	beq t0, x0, EXIT	#t0=0则完成n位计算
	addi t0, t0, -1
	sw t1, (a4)
	sw t2, 4(a4)		#存储
	...//外设输出
OUTPUT:	
	...//外设输出
LOOP2:
	...//外设输出
NOTZERO:
	...//外设输出
NEXT:
	...//外设输出
ENDL:
	...//外设输出
	addi a4, a4, 8		#地址增加8字节，即64位，一个大整数的长度
	add t6, t2, t4
	add a7, x0, t6
	sltu a7, a7, t2		#若进位，则a7<t2必然成立，a7=1，否则a7=0
	add t5, t1, t3
	add t5, t5, a7		#t5+=a7，即若进位则加t5+=1
	add t1, x0, t3
	add t2, x0, t4
	add t3, x0, t5
	add t4, x0, t6		#数值左移
	blt x0, t0, LOOP
EXIT:	
	nop
```

#### 用于实现外设输入、输出的核心代码（不支持大整数）

```assembly
INPUT:	
	lb a5, 0x00007f00
	beq a5, x0, INPUT	#轮询
	lw a0, 0x00007f04
	addi a0, a0, -10	#判断是否为回车，是回车则结束输入
	beq a0, x0, FLS
	addi a0, a0, -38	#求出对应数字
	addi t0, a0, 0		#对应数字存入a0
	add t0, t0, a6		#将上一个输入值的10倍(a6)与当前输入值(t0)相加，存入a6
	slli a6, t0, 3
	add a6, a6, t0
	add a6, a6, t0		#a6=10*t0
	jal x0, INPUT
FLS:
	...
LOOP:	
	...
	addi a1, x0, 8		#输出8次，每次1位
	addi a2, x0, 0
OUTPUT:	lb a5, 0x00007f08
	beq a5, x0, OUTPUT	#轮询
	sll a6, t2, a2		#左移a2位
	srli a6, a6, 28		#右移(7*4)位，取出对应4位，即从左到右，逐4位取出
	addi a2, a2, 4
	addi a1, a1, -1
	beq a6, x0, OUTPUT	#若为0，则是前导零，不输出
	bne a6, x0, NOTZERO	#首个不为0，开始输出
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
	bne a1, x0, LOOP2	#若a1=0，结束输出
	addi a6, x0, 10
ENDL:	lb a5, 0x00007f08
	beq a5, x0, ENDL	#轮询
	sw a6, 0x00007f0c, a0	#输出a6=10，即换行符
	...
EXIT:	
	nop
```

