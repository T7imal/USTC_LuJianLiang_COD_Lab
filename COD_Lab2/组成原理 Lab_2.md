# Lab2 Report

## 实验目的与内容

1. 掌握寄存器堆的功能、时序和应用，编写寄存器堆设计文件
1. 掌握存储器的功能、时序
1. 熟练掌握数据通路和控制器的设计和描述方法，完成FIFO电路设计

## 逻辑设计

#### 【框图】

**寄存器堆框图**

![image-20230418225849409](C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230418225849409.png)

**分布式存储器框图**

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230418230029630.png" alt="image-20230418230029630" style="zoom:150%;" />

**块式存储器框图**

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230418230129524.png" alt="image-20230418230129524" style="zoom:150%;" />

**FIFO框图**

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230418230512347.png" alt="image-20230418230512347" style="zoom:150%;" />

**LCU框图**

![image-20230418231133604](C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230418231133604.png)

**SDU框图**

![image-20230418231452956](C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230418231452956.png)

#### 【LCU状态机的状态转换图】

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230418233314879.png" alt="image-20230418233314879" style="zoom: 30%;" />

#### 【核心设计代码】

**寄存器堆设计**

```verilog
module register_file //三端口32 xWIDTH寄存器堆
#(parameter WIDTH = 4) //数据宽度和存储器深度
( 
    input clk, //时钟（上升沿有效）
    input[4 : 0] ra0, //读端口0地址
    output[WIDTH - 1 : 0] rd0, //读端口0数据
    input[4: 0] ra1, //读端口1地址
    output[WIDTH - 1 : 0] rd1, //读端口1数据
    input[4 : 0] wa, //写端口地址
    input we, //写使能，高电平有效
    input[WIDTH - 1 : 0] wd //写端口数据
);
    reg [WIDTH - 1 : 0] regfile[0 : 7];
    reg [5 : 0] temp;

    initial begin//仿真中初始化寄存器堆为0
        for (temp=0; temp<32; temp=temp+1) begin
            regfile[temp]=0;
        end
    end

    assign rd0 = regfile[ra0], rd1 = regfile[ra1];//异步输出

    always @ (posedge clk) begin
        if(we)begin
            if(wa)
                regfile[wa] <= wd;
            else//若写地址为0，写入0
                regfile[wa] <= 0;
        end
    end
endmodule
```

**LCU模块设计**

```verilog
module LCU(
    input clk,
    input rst,
    input [3:0] in,
    input enq,
    input deq,
    input [3:0] rd0,
    input en_dist,  //读取例化的单端口分布式存储器
    output [3:0] out,
    output full,
    output empty,
    output [2:0] ra0,
    output [2:0] wa,
    output [3:0] wd,
    output we,
    output [7:0] valid,
    output [2:0] rp1
);
    reg [1:0] c_state=0;
    reg [1:0] n_state=0;
    reg enq_1=0, enq_2=0;
    reg deq_1=0, deq_2=0;
    reg [3:0] wdr=0;
    reg [2:0] wp=0, rp=0, ra0r1=0, ra0r2=0, war=0;
    reg fullr=0, emptyr=1, wer=0;
    reg [7:0] validr=0;
    wire [3:0] spo;
	//三段式状态机
    always @(posedge clk) begin
        if(rst)begin
            c_state<=2'b00;
        end
        else c_state<=n_state;
    end
	//取按钮边沿信号
    always @(posedge clk) begin
        enq_1<=enq_2;
        enq_2<=enq;
        deq_1<=deq_2;
        deq_2<=deq;
    end

    always @(*) begin
        n_state=c_state;
        if(!rst)begin
            case(c_state)
                2'b00:begin
                    n_state=(~enq_1&enq_2)?2'b01:2'b00; 
                end
                2'b01:begin
                    if(wp==rp && emptyr)//出队且队空，进入00状态
                        n_state=2'b00;
                    else if(wp==rp && fullr)//入队且队满，进入10状态
                        n_state=2'b10;
                    else
                        n_state=2'b01;
                end
                2'b10:begin
                    n_state=(~deq_1&deq_2)?2'b01:2'b10; 
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if(rst)begin
            wp<=0;
            rp<=0;
            fullr<=0;
            emptyr<=1;
            validr<=8'h01;
        end
        else begin
            case(c_state)
                2'b00:begin//00状态仅能入队
                    wer<=0;
                    if(~enq_1&enq_2)begin
                        war<=wp;
                        validr[wp]<=1;
                        wp<=(wp+1)%8;
                        //wdr<=in;
                        wer<=1;
                        emptyr<=0;
                    end
                end
                2'b01:begin
                    wer<=0;
                    if(~enq_1&enq_2)begin
                        war<=wp;
                        validr[wp]<=1;
                        wp<=(wp+1)%8;
                        //wdr<=in;
                        wer<=1;
                        if((wp+1)%8==rp) fullr<=1;
                    end
                    if(~deq_1&deq_2)begin
                        ra0r1<=rp;
                        validr[rp]<=0;
                        rp<=(rp+1)%8;
                        if(wp==(rp+1)%8) emptyr<=1;
                    end
                end
                2'b10:begin//10状态仅能出队
                    wer<=0;
                    if(~deq_1&deq_2)begin
                        ra0r1<=rp;
                        validr[rp]<=0;
                        rp=(rp+1)%8;
                        fullr<=0;
                    end
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if(en_dist)
            ra0r2<=rp;//当sw[4]为1时，读取当前队头位置
    end

    assign ra0=(en_dist)?ra0r2:ra0r1;//当sw[4]为1时，读取当前队头数值
    assign out=(en_dist)?spo:rd0;//当sw[4]为1时，输出当前以队头数值为地址的存储器中的数值
    assign full=fullr;
    assign empty=emptyr;
    assign wa=war;
    assign wd=in;
    assign we=wer;
    assign valid=validr;
    assign rp1=rp;
    //例化分布式存储器
    dist_mem_gen_0 dist_mem_gen_0 (
        ...
    );  

endmodule
```

**SDU测试电路**

```verilog
module SDU(
    input clk,
    input [3:0] rd1,
    input [7:0] valid,
    input [2:0] rp1,
    output [2:0] ra1,
    output [2:0] an,
    output [3:0] seg
);
    reg [2:0] temp=0;
    reg [17:0] clk_400=0;
    reg [2:0] ra1r=0, anr=0, offset=0;

    always @(posedge clk) begin//周期为400Hz
        if(clk_400==18'h3d08f)
            clk_400<=0;
        else
        clk_400<=clk_400+1;
    end

    always @(posedge clk) begin
        if(valid==0)begin//队空时，默认输出0位置为0
            ra1r<=0;
            anr<=0;
        end
        else begin
            if(clk_400==0)begin
                if(valid[temp])begin
                    ra1r<=temp;
                    anr<=temp-rp1;//使队头元素永远位于最右侧
                end
                temp<=(temp+1)%8;
            end
        end
    end

    assign ra1=ra1r;
    assign an=anr;
    assign seg=rd1;

endmodule
```

**FIFO顶层电路**

```verilog
//例化各模块连接
module FIFO (
    input ...
    output ...
);
    wire ...

    LCU LCU(
        ...
    );

    SDU SDU(
        ...
    );

    register_file_8x4 register_file_8x4(
        ...
    );
```

## 仿真结果与分析

**各种存储器的不同时序特征**

分布式存储器：异步读取，同步写入，写入读取的位置时，读出的值马上变为新的值

![image-20230419000155733](C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230419000155733.png)

块式存储器（write first）：同步读取，同步写入，写入读取的位置时，读出的值在接下来第一个时钟上升沿变为新的值

![image-20230419000242912](C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230419000242912.png)

块式存储器（read first）：同步读取，同步写入，写入读取的位置时，读出的值在接下来第二个时钟上升沿变为新的值

![image-20230419000303695](C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230419000303695.png)

块式存储器（no change）：同步读取，同步写入，写入读取的位置时，读出的值在写使能信号结束后，第一个时钟上升沿变为新的值

![image-20230419000322897](C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230419000322897.png)

块式存储器（primitives）：与块式存储器（write first）相同，但同步延迟多1时钟周期

![image-20230419000417602](C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230419000417602.png)

块式存储器（core）：与块式存储器（write first）相同，但同步延迟多1时钟周期

![image-20230419000423285](C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230419000423285.png)

块式存储器（primitives and core）：与块式存储器（write first）相同，但同步延迟多2时钟周期

![image-20230419000429636](C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230419000429636.png)

**寄存器堆测试电路仿真**

展示了向寄存器堆的0位置写入，以及同步写入和异步读取

![image-20230419001230868](C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230419001230868.png)

**FIFO测试电路仿真**

展示了队列的满和空状态、输出信号，以及按下`sw[4]`时的输出，不包括数码管信号

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230418235123962.png" alt="image-20230418235123962"  />

## 电路设计与分析

**FIFO电路RTL分析电路图**

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230418235550861.png" alt="image-20230418235550861" style="zoom: 67%;" />

**LCU电路RTL分析电路图**

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230418235636564.png" alt="image-20230418235636564" style="zoom:67%;" />

**SDU电路RTL分析图**

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230418235802961.png" alt="image-20230418235802961" style="zoom:67%;" />

**16*4寄存器堆电路RTL分析图**

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230418235732291.png" alt="image-20230418235732291" style="zoom:67%;" />

## 总结

本次实验完成了寄存器堆模块、LCU模块、SDU模块的设计、仿真，FIFO电路的设计、仿真和下载测试

掌握了寄存器堆功能、时序及其应用

掌握了存储器的功能、时序

熟悉了verilog语言中的状态机设计