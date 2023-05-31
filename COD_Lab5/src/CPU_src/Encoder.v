module Encoder (
    input jal,
    input jalr,
    input br,
    output reg [1:0] pc_sel
);
    initial pc_sel=0;
    always @(*) begin
        if(jalr)
            pc_sel=1;
        else if(br)
            pc_sel=2;
        else if(jal)    //由于jal提前判断，优先级最低
            pc_sel=3;
        else
            pc_sel=0;
    end
endmodule