`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/10 20:27:46
// Design Name: 
// Module Name: FIFO
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FIFO (
    input clk, rst, //时钟（上升沿有效）、同步复位（高电平有效）
    input enq, //入队列使能，高电平有效
    input [3:0] in, //入队列数据
    input deq, //出队列使能，高电平有效
    input en_dist,   //读取例化的单端口分布式存储器
    output [3:0] out, //出队列数据
    output full,empty, //队列满和空标志
    output [2:0] an, //数码管选择
    output [3:0] seg //数码管数据
);
    wire [3:0] wd, rd0, rd1, spo;
    wire [2:0] wa, ra0, ra1, rp1;
    wire we;
    wire [7:0] valid;

    LCU LCU(
        .clk(clk),
        .rst(rst),
        .in(in),
        .enq(enq),
        .deq(deq),
        .rd0(rd0),
        .en_dist(en_dist),
        .out(out),
        .full(full),
        .empty(empty),
        .ra0(ra0),
        .wa(wa),
        .wd(wd),
        .we(we),
        .valid(valid),
        .rp1(rp1)
    );

    SDU SDU(
        .clk(clk),
        .rd1(rd1),
        .valid(valid),
        .ra1(ra1),
        .an(an),
        .seg(seg),
        .rp1(rp1)
    );

    register_file_8x4 register_file_8x4(
        .clk(clk),
        .ra0(ra0),
        .rd0(rd0),
        .ra1(ra1),
        .rd1(rd1),
        .wa(wa),
        .we(we),
        .wd(wd)
    );

    
endmodule

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

    always @(posedge clk) begin
        if(rst)begin
            c_state<=2'b00;
        end
        else c_state<=n_state;
    end

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
                    if(wp==rp && emptyr)
                        n_state=2'b00;
                    else if(wp==rp && fullr)
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
                2'b00:begin
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
                2'b10:begin
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
            ra0r2<=rp;
    end

    assign ra0=(en_dist)?ra0r2:ra0r1;
    assign out=(en_dist)?spo:rd0;
    assign full=fullr;
    assign empty=emptyr;
    assign wa=war;
    assign wd=in;
    assign we=wer;
    assign valid=validr;
    assign rp1=rp;
    
    dist_mem_gen_0 dist_mem_gen_0 (
        .a(rd0),      // input wire [3 : 0] a
        .spo(spo)  // output wire [3 : 0] spo
    );  

endmodule

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

    always @(posedge clk) begin
        if(clk_400==18'h3d08f)
            clk_400<=0;
        else
        clk_400<=clk_400+1;
    end

    always @(posedge clk) begin
        if(valid==0)begin
            ra1r<=0;
            anr<=0;
        end
        else begin
            if(clk_400==0)begin
                if(valid[temp])begin
                    ra1r<=temp;
                    anr<=temp-rp1;
                end
                temp<=(temp+1)%8;
            end
        end
    end

    assign ra1=ra1r;
    assign an=anr;
    assign seg=rd1;

endmodule

module register_file_8x4 //三端口32 xWIDTH寄存器堆
#(parameter WIDTH = 4) //数据宽度和存储器深度
( 
    input clk, //时钟（上升沿有效）
    input[2 : 0] ra0, //读端口0地址
    output[WIDTH - 1 : 0] rd0, //读端口0数据
    input[2: 0] ra1, //读端口1地址
    output[WIDTH - 1 : 0] rd1, //读端口1数据
    input[2 : 0] wa, //写端口地址
    input we, //写使能，高电平有效
    input[WIDTH - 1 : 0] wd //写端口数据
);
    reg [WIDTH - 1 : 0] regfile[0 : 7];
    reg [3 : 0] temp;

    initial begin
        for (temp=0; temp<8; temp=temp+1) begin
            regfile[temp]=0;
        end
    end

    assign rd0 = regfile[ra0], rd1 = regfile[ra1];

    always @ (posedge clk) begin
        if(we)begin
            if(wa)
                regfile[wa] <= wd;
            else
                regfile[wa] <= 0;
        end
    end

endmodule