module NPC_SEL (
    input [31:0] pc_add4,
    input [31:0] pc_jal_br,
    input [31:0] pc_jalr,
    input jal,
    input jalr,
    input br,
    output reg [31:0] pc_next
);
    always @(*) begin
        pc_next=pc_add4;
        if(jal||br)
            pc_next=pc_jal_br;
        if(jalr)
            pc_next=pc_jalr;
    end
endmodule