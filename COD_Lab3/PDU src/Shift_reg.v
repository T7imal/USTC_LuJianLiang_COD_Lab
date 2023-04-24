`timescale 1ns / 1ps

module Shift_reg(
    input rst,
    input clk,          // Work at 100MHz clock

    input [31:0] din,   // Data input  
    input [3:0] hex,    // Hexadecimal code for the switches
    input add,          // Add signal
    input del,          // Delete signal
    input set,          // Set signal
    
    output reg [31:0] dout  // Data output
);
    reg [31:0] d;

    always @(posedge clk) begin
        if(rst)
            d<=0;
        else begin
            if(set)
                d<=din;
            if(add)
                d<={d[27:0],hex};
            if(del)
                d<={4'b0000, d[31:4]};
        end 
    end
  
    always @(*) begin
        dout=d;
    end

endmodule

