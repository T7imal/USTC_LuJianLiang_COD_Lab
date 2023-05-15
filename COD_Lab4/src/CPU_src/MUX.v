module MUX1 (
    input [31:0] src0,
    input [31:0] src1,
    input sel,
    output reg [31:0] res
);
    always @(*) begin
        case (sel)
            0: res=src0;
            1: res=src1;
        endcase
    end
endmodule

module MUX2 (
    input [31:0] src0,
    input [31:0] src1,
    input [31:0] src2,
    input [31:0] src3,
    input [1:0] sel,
    output reg [31:0] res
);
    always @(*) begin
        case (sel)
            2'h0: res=src0;
            2'h1: res=src1;
            2'h2: res=src2;
            2'h3: res=src3;
        endcase
    end
endmodule