module Immediate (
    input [2:0] imm_type,
    input [31:0] inst,
    output reg [31:0] imm
);
    always @(*) begin
        case (imm_type)
            3'h1: imm={{20{inst[31]}}, inst[31:20]};                                //I-Type
            3'h2: imm={{20{inst[31]}}, inst[31:25], inst[11:7]};                    //S-Type
            3'h3: imm={{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], {1'b0}};   //B-Type
            3'h4: imm={inst[31:12], 12'b0};                                         //U-Type
            3'h5: imm={{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], {1'b0}}; //J-Type
            default: imm=32'b0;
        endcase
    end
endmodule