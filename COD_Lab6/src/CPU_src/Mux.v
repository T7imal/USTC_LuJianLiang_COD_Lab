`timescale 1ns / 1ps

module Mux1 #(WIDTH = 32) (
    input [WIDTH-1: 0]          src0,
    input [WIDTH-1: 0]          src1,
    input                       sel,

    output reg [WIDTH-1: 0]     res
);  

    always @(*) begin
        case (sel)
            1'b0: res = src0;
            1'b1: res = src1;
        endcase // We don't need default here
    end

endmodule

module Mux2 #(WIDTH = 32) (
    input [WIDTH-1: 0]          src0,
    input [WIDTH-1: 0]          src1,
    input [WIDTH-1: 0]          src2,
    input [WIDTH-1: 0]          src3,
    input [1:0]                 sel,

    output reg [WIDTH-1: 0]     res
);  

    always @(*) begin
        case (sel)
            2'b00: res = src0;
            2'b01: res = src1;
            2'b10: res = src2;
            2'b11: res = src3;
        endcase // We don't need default here
    end

endmodule