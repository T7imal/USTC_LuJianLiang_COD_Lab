`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/22 20:59:57
// Design Name: 
// Module Name: Lab1
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


module Clock(
    input clk,
    input rst,
    output [2:0] hour,
    output [3:0] min,
    output [4:0] sec
);

    Sec Sec(.clk(clk),.rst(rst),.sec(sec));
    Min Min(.clk(clk),.rst(rst),.sec(sec),.min(min));
    Hour Hour(.clk(clk),.rst(rst),.sec(sec),.min(min),.hour(hour));
    

endmodule

module Sec (
    input clk,
    input rst,
    output reg [4:0] sec
);
    always @(posedge clk or posedge rst) begin
        if(rst==1)
            sec<=0;
        else begin
            if(sec==5'h13)
                sec<=5'h0;
            else
            sec<=sec+1;
        end
    end
endmodule

module Min (
    input clk,
    input rst,
    input  [4:0] sec,
    output reg [3:0] min
);
    always @(posedge clk or posedge rst) begin
        if(rst==1)
            min<=0;
        else begin
            if (min==4'h9 && sec==5'h13)
                min<=4'h0;
            else begin
                if(sec==5'h13)
                    min<=min+1;
            end
        end
    end
endmodule

module Hour (
    input clk,
    input rst,
    input [3:0] min,
    input [4:0] sec,
    output reg [2:0] hour
);
    always @(posedge clk or posedge rst) begin
        if(rst==1)
            hour<=0;
        else begin
            if(hour==3'h4 && min==4'h9 && sec==5'h13)
                hour<=3'h0;
            else begin
                if(min==4'h9 && sec==5'h13)
                    hour<=hour+1; 
            end
        end
    end
endmodule
