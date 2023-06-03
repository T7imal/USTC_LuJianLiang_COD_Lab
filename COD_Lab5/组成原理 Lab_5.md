# Lab3 Report

## 实验原理

### 实验内容

1. 深入理解五级流水线CPU数据通路、各种基本组件
2. 完成流水线CPU的硬件设计，并完成仿真
4. 将PDU接入CPU并完成上板测试
5. 在CPU上运行汇编程序

### 设计流程

#### 数据通路

<img src="C:\Users\hwc\Desktop\卢建良COD实验\COD_Lab5\src\figs\datapath_选做1.png" alt="datapath_选做1" style="zoom: 25%;" />

<img src="C:\Users\hwc\Desktop\卢建良COD实验\COD_Lab5\src\figs\Top_module.png" alt="Top_module"  />

#### 关键模块设计

##### 冒险模块（Hazard）

若`ex`段寄存器读使能与`mem`或`wb`段寄存器写使能相同，则存在数据冒险，需要前递；若`mem`段的指令为`lw`指令，则需要插入气泡

若分支指令或跳转指令跳转，则产生控制冒险，需要冲刷`ex`段之前的寄存器，也即`id`和`ex`段寄存器

但没有解决连续出现数据冒险，且第二个数据冒险需要插入气泡时，第一个数据冒险的前递数据丢失问题

由于`jal`指令前提到id阶段即跳转，jal指令仅插入一时钟周期气泡，也即仅冲刷`id`段寄存器

```verilog
module Hazard (
    input [4:0] rf_ra0_ex,
    input [4:0] rf_ra1_ex,
    input rf_re0_ex,
    input rf_re1_ex,
    input [4:0] rf_wa_mem,
    input rf_we_mem,
    input [1:0] rf_wd_sel_mem,
    input [31:0] alu_ans_mem,
    input [31:0] pc_add4_mem,
    input [31:0] imm_mem,
    input [4:0] rf_wa_wb,
    input rf_we_wb,
    input [31:0] rf_wd_wb,
    input [1:0] pc_sel_ex,
    output reg rf_rd0_fe,
    output reg rf_rd1_fe,
    output reg [31:0] rf_rd0_fd,
    output reg [31:0] rf_rd1_fd,
    output reg stall_if,
    output reg stall_id,
    output reg stall_ex,
    output reg flush_if,
    output reg flush_id,
    output reg flush_ex,
    output reg flush_mem
);
    reg [31:0] rf_wd_mem;
    always @(*) begin
        rf_wd_mem=0;
        case (rf_wd_sel_mem)
            0: rf_wd_mem=alu_ans_mem;
            1: rf_wd_mem=pc_add4_mem;
            3: rf_wd_mem=imm_mem;       //rf_wd_sel_mem==2时，写回值源于数据存储器，需要插入气泡
        endcase
    end

    always @(*) begin
        rf_rd0_fe=0; rf_rd0_fd=0; rf_rd1_fe=0; rf_rd1_fd=0;
        stall_if=0; stall_id=0; stall_ex=0;
        flush_if=0; flush_id=0; flush_ex=0; flush_mem=0;
        if(rf_we_wb)begin   //上上条指令存在写回寄存器堆
            if(rf_re0_ex==1 && rf_ra0_ex==rf_wa_wb)begin    //这一条指令需要读寄存器堆，且所读寄存器与上一条指令写回的寄存器相同
                rf_rd0_fe=1;
                rf_rd0_fd=rf_wd_wb;
            end
            if(rf_re1_ex==1 && rf_ra1_ex==rf_wa_wb)begin    //这一条指令需要读寄存器堆，且所读寄存器与上一条指令写回的寄存器相同
                rf_rd1_fe=1;
                rf_rd1_fd=rf_wd_wb;
            end
        end
        if(rf_we_mem)begin  //上一条指令存在写回寄存器堆
            if(rf_re0_ex==1 && rf_ra0_ex==rf_wa_mem)begin   //这一条指令需要读寄存器堆，且所读寄存器与上一条指令写回的寄存器相同
                if(rf_wd_sel_mem==2)begin   //上一条指令写回值源于数据存储器，需要插入气泡
                    stall_if=1;
                    stall_id=1;
                    stall_ex=1;
                    flush_mem=1;
                end
                rf_rd0_fe=1;
                rf_rd0_fd=rf_wd_mem;
            end
            if(rf_re1_ex==1 && rf_ra1_ex==rf_wa_mem)begin   //这一条指令需要读寄存器堆，且所读寄存器与上一条指令写回的寄存器相同
                if(rf_wd_sel_mem==2)begin   //上一条指令写回值源于数据存储器，需要插入气泡
                    stall_if=1;
                    stall_id=1;
                    stall_ex=1;
                    flush_mem=1;
                end
                rf_rd1_fe=1;
                rf_rd1_fd=rf_wd_mem;
            end
        end
        if(pc_sel_ex==1 || pc_sel_ex==2)begin    //jalr, br
            //flush_if=1;   //没有必要
            flush_id=1;
            flush_ex=1;
        end
        if(pc_sel_ex==3)begin   //jal 提前跳转，只清空前两阶段寄存器
            //flush_if=1;   //没有必要
            flush_id=1;
        end
    end
endmodule
```

#### 选做1

参考修改后的数据通路，我在`id`段中加入了一个加法器，用于提前计算`jal`指令的跳转地址，并将该信号传递到`MUX2 @npc_sel`模块中，作为`jal`指令出现时跳转的地址

将`Encoder @pc_sel_gen`模块输入中的`jal_ex`信号改为了`jal_id`信号，即`id`段的jal跳转信号

```verilog
module Encoder (
    input jal,
    input jalr,
    input br,
    output reg [1:0] pc_sel
);
    initial pc_sel=0;
    always @(*) begin
        if(jalr)
            pc_sel=1;
        else if(br)
            pc_sel=2;
        else if(jal)    //由于jal提前判断，优先级最低
            pc_sel=3;
        else
            pc_sel=0;
    end
endmodule
```

当`jal`指令紧随其他跳转指令时，`jal_id`和`br_ex`或`jalr_ex`同时为`1`时`jal`指令不应该生效，所以这里`jal`信号的判断优先级最低

## 思考题

假设单周期CPU时钟周期为$100ns$，流水线CPU各级中所需时间最多的为`mem`段，为$30ns$，则最小需要时钟周期为$30ns$

假设平均每$20$条指令产生$1$次气泡，则对于$100$条指令的程序，单周期和流水线CPU的运行时间分别为
$$
t_{单周期}=100\times100ns=1\times10^4ns\\
t_{流水线}=(100+5+4)\times30ns=3.27\times10^3ns
$$
所需时间比单周期CPU短$67.3\%$

## 体会

接线真是体力活，就算是查找替换也是体力活