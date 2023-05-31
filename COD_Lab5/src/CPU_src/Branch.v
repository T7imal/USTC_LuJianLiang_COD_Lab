module Branch (
    input [31:0] op1,
    input [31:0] op2,
    input [1:0] br_type,
    output reg br
);
    always @(*) begin
        br=0;
        case (br_type)
            3'h1:begin
                br=(op1==op2)?1:0;  //beq
            end
            3'h2:begin
                br=($signed(op1)<$signed(op2))?1:0; //blt
            end
        endcase
    end
endmodule