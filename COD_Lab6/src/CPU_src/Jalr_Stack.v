module Jalr_Stack (
    input clk,
    input rst,
    input [31:0] pc_if,
    input [31:0] inst_if,
    input [1:0] top_fix,
    output reg [31:0] jalr_addr
);
    reg [31:0] jas[0:63];  //jalr addr stack
    reg [5:0] top;

    integer i=0;

    initial begin
        top=1;
        for(i=0; i<64; i=i+1)begin
            jas[i]=0;
        end
    end

    always @(*) begin
        jalr_addr=jas[top-1];
    end

    always @(posedge clk) begin
        if(rst)begin
            top<=1;
        end
        else begin
            top<=top+top_fix;
            if(inst_if[6:0]==7'b1100111)begin //jalr, 出栈
                top<=top+top_fix-1;
            end
            if(inst_if[6:0]==7'b1101111)begin //jal, 入栈
                jas[top]=pc_if+4;
                top<=top+top_fix+1;
            end
        end
    end
endmodule