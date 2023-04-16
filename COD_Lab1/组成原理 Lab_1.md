# Lab1 Report

## 实验目的与内容

1. 掌握ALU的功能和设计，使用Verilog语言设计ALU模块
1. 掌握数据通路和有限状态机的设计方法，设计斐波那契数列计算电路
1. 掌握组合电路、时序电路，以及参数化、结构化的Verilog描述方法，并使用Verilog语言设计斐波那契数列计算电路

## 逻辑设计

#### 【框图和数据通路】

**ALU框图**

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230408213449764.png" alt="image-20230408213449764" style="zoom:67%;" />

**ALU_Test框图**

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230408213311450.png" alt="image-20230408213311450" style="zoom: 67%;" />

**FLS框图**

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230408220250498.png" alt="image-20230408220250498" style="zoom:67%;" />

**FLS数据通路**

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230408233302615.png" alt="image-20230408233302615" style="zoom: 38%;" />

#### 【FLS状态机的状态转换图】

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230408223622851.png" alt="image-20230408223622851" style="zoom: 25%;" />

#### 【核心设计代码】

**ALU模块设计**

```verilog
always @(*) begin
    yreg=0;
    ofreg=0;
    case (func)
        4'b0000:begin
            yreg=a+b;
            if((a[WIDTH-1]&b[WIDTH-1]&~yreg[WIDTH-1])|(~a[WIDTH-1]&~b[WIDTH-1]&yreg[WIDTH-1]))
                ofreg=1;
        end
        4'b0001:begin
            yreg=a+~b+1;
            if((a[WIDTH-1]&~b[WIDTH-1]&~yreg[WIDTH-1])|(~a[WIDTH-1]&b[WIDTH-1]&yreg[WIDTH-1]))
                ofreg=1;
        end
        4'b0010:begin
            if(a==b)
                yreg=1;
        end
        4'b0011:begin
            if(a<b)
                yreg=1;
        end
        4'b0100:begin
            if($signed(a)<$signed(b))
                yreg=1;
        end
        4'b0101:begin
            yreg=a&b;
        end
        4'b0110:begin
            yreg=a|b;
        end
        4'b0111:begin
            yreg=a^b;
        end
        4'b1000:begin
            yreg=a>>b;
        end
        4'b1001:begin
            yreg=a<<b;
        end
        default:begin
            yreg=0;
            ofreg=0;
        end
    endcase
end
assign y=yreg;
assign of=ofreg;
```

**ALU测试电路**

```verilog
always @(*) begin//分时复用
    ena=0;
    enb=0;
    enf=0;
    if(en)begin
        case(sel)
            2'b00:ena=1;
            2'b01:enb=1;
            2'b10:enf=1;
            default:begin
                ena=0;
                enb=0;
                enf=0;
            end
        endcase
    end
    else begin
        ena=0;
        enb=0;
        enf=0;
    end
end

always @(posedge clk) begin//分时复用
    if(ena)
        areg<=x;
    else if(enb)
        breg<=x;
    else if(enf)
        freg<=x[3:0];
    else begin
        areg<=areg;
        breg<=breg;
        freg<=freg;
    end
end

alu alu_1 (
    .a(areg),
    .b(breg),
    .func(freg),
    .y(y),
    .of(of)
);
```

**FLS电路**

```verilog
/*有限状态机三段式其一，当前状态的复位或赋值*/

/*取en上升沿信号~en_1&en_2*/

/*状态转换，当检测到en上升沿时状态变化，状态包括2'b00，2'b01，2'b10*/

always @(posedge clk) begin//左移寄存器，计算斐波那契数列
    f1<=f1;
    f2<=f2;
    if(rst)begin
        f1<=0;
        f2<=0;
    end
    else begin
        case(c_state)
            2'b00:begin
                if(~en_1&en_2)begin
                    f2<=d;
                end
            end
            2'b01:begin
                if(~en_1&en_2)begin
                    f1<=f2;
                    f2<=d;
                end
            end
            2'b10:begin
                if(~en_1&en_2)begin
                    f1<=f2;
                    f2<=f3;
                end
            end
        endcase 
    end
end

always@(*) func=d[3:0];//实时改变FLS计算模式

assign f=f2;

alu #(.WIDTH(7)) alu_2  (
    .a(f1),
    .b(f2),
    .func(func),
    .y(f3),
    .of()
);
```

## 仿真结果与分析

**ALU测试电路仿真**

输入两操作数分别为`2'b10`和`2'b01`，ALU计算模式从`4'b0000`到`4'b1001`，`y[5:0]`为不同模式下输出的结果

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230408174604731.png" alt="image-20230408174604731"  />

**FLS电路仿真**

输入两操作数分别为`2`和`3`，使ALU在加法模式下运行，`f[6:0]`为输出的结果

![image-20230408175423164](C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230408175423164.png)

输入两操作数分别为`2`和`3`，使ALU在先加法模式下运行，后在减法模式下运行，`f[6:0]`为输出的结果

![image-20230408180013568](C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230408180013568.png)

## 电路设计与分析

**FLS电路RTL分析电路图**

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230408180326284.png" alt="image-20230408180326284" style="zoom:67%;" />

**ALU电路RTL分析电路图**

<img src="C:\Users\hwc\AppData\Roaming\Typora\typora-user-images\image-20230408180524589.png" alt="image-20230408180524589" style="zoom: 80%;" />

## 总结

本次实验完成了ALU模块的设计，ALU测试电路的设计、仿真和下载测试，FLS电路的设计、仿真和下载测试。我深入了解了有限状态机三段式的模块化编程方法，并学习了使用数据通路、状态转换图的设计方法