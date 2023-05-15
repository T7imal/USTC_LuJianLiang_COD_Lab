module Branch (
    input [31:0] op1,
    input [31:0] op2,
    input [2:0] br_type,
    output reg br
);
    always @(*) begin
        br=0;
        case (br_type)
            3'h1:begin
                br=(op1==op2)?1:0;  //beq
            end
            3'h2:begin
                br=(op1!=op2)?1:0;  //bne
            end
            3'h3:begin
                br=($signed(op1)<$signed(op2))?1:0; //blt
            end
            3'h4:begin
                br=($signed(op1)>=$signed(op2))?1:0;    //bge
            end
            3'h5:begin
                br=(op1<op2)?1:0;   //bltu
            end
            3'h6:begin
                br=(op1>=op2)?1:0;  //bgeu
            end
        endcase
    end
endmodule