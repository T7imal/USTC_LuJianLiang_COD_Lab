.text
lui s9,8 #s9 is output data reg
addi s9,s9,0xffffff0c
lui s10,8 #s10 is input state reg
addi s10,s10,0xffffff00
lui s11,8 #s11 is input data reg
addi s11,s11,0xffffff04
addi s0,x0,0 # get offset in s0
addi s2,x0,2 # m store in s2
slli s2,s2,2
addi s1,s1,30 # get n in s1
addi s1,s1,-1
beq s1 x0 end
addi a2,x0,1 #f(0)=1,s3 and s4 is f(n-2)
addi a3,x0,0
jal sw_m # sw fisrt element
jal move2 # a0,a1=f(n-1) ,and a2,a3 = f(n)
jal sw_m # sw second one
jal move1 
loop:
	addi s1,s1,-1
	beq s1 x0 end
	jal add_m 
	jal move1
	jal move2
	jal sw_m
	#jal output_m
	beq x0,x0,loop


sw_m: # addr is s0,write the m bits word from a2,a3
	sw a2,0(s0)
	sw a3,4(s0)
	add s0,s0,s2
	jalr ra
	
move1: # move the data in a1,a0 to s3,s4
	addi s3,a0,0
	addi s4,a1,0
	jalr ra

move2: # move the data in a2,a3 to a1,a0
	addi a1,a3,0
	addi a0,a2,0
	jalr ra

add_m: # add the m bits
	add a2,a0,s3
	srli t3,a0,1
	srli t4,s3,1
	add t5,t4,t3
	addi a3,x0,0
	add a3,a3,a1
	add a3,a3,s4
	jalr ra
	
receive:
	addi s8,x0,1 # s8 = 1,this is for compare with the ready bit
	addi s6,s6,0 # s6 is cleared
	lw a7,0(s10) # a7 = ready bit 
	blt a7,s8,receive
	lw a6,0(s11) # n = input data
	addi a6,a6,-10
	beq a6,x0,next_cyc
	addi a6,a6,-38
	slli s7,s6,3 # s7 = 8 s6
	slli s6,s6,1
	add s6,s6,s7
	add s6,s6,a6
	beq x0,x0,receive
next_cyc:	
	addi s1,s6,0 
	jalr ra
	
output_m: # output the 2 data from addr of s0
	addi s6,x0,8 # i = 8
	addi s7,x0,15 # s7 = 0xf000 0000
	addi a6,x0,10 # a6=0xa
	addi s8,a3,0 # s8 = a3
	slli s7,s7,28
	beq a3,x0,next
	
out_loop1:
	addi s6,s6,-1
	and a7,s7,s8 # a7 = highedt bits of a3
	srli a7,a7,28 # move it to lower bits
	slli s8,s8,4
	beq a7,x0,out_loop1# if current is 0,then next loop
	bge a7,a6,out_a1 # if current is a,b,c, then jump to out_a
	beq x0,x0,digit1
start1:
	addi s6,s6,-1
	and a7,s7,s8 # a7 = highedt bits of a3
	srli a7,a7,28 # move it to lower bits
	slli s8,s8,4
	bge a7,a6,out_a1 # if current is a,b,c, then jump to out_a
digit1:
	addi a7,a7,48
	sw a7,0(s9)
	beq x0,x0,branch1
out_a1:
	addi a7,a7,87
	sw a7,0(s9)
branch1:
	bne s6,x0,start1 # if cnt(s6)==0 ,then output next string
next:
	addi s6,x0,8
	addi s8,a2,0
	beq a2,x0,end_out
out_loop2:
	addi s6,s6,-1
	and a7,s7,s8 # a7 = highedt bits of a3
	srli a7,a7,28 # move it to lower bits
	slli s8,s8,4
	beq a7,x0,out_loop2# if current is 0,then next loop
	bge a7,a6,out_a2 # if current is a,b,c, then jump to out_a
	beq x0,x0,digit2
start2:
	addi s6,s6,-1
	and a7,s7,s8 # a7 = highedt bits of a3
	srli a7,a7,28 # move it to lower bits
	slli s8,s8,4
	bge a7,a6,out_a2 # if current is a,b,c, then jump to out_a
digit2:
	addi a7,a7,48
	sw a7,0(s9)
	beq x0,x0,branch2
out_a2:
	addi a7,a7,87
	sw a7,0(s9)
branch2:
	bne s6,x0,start2 # if cnt(s6)==0 ,then return
end_out:
	addi a6,x0,10
	sw a6,0(s9)
	jalr ra

end :
nop
