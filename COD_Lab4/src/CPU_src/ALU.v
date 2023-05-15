module ALU #(parameter WIDTH = 32) //数据宽度
(
input [WIDTH-1:0] alu_op1, alu_op2, //两操作数（对于减运算，a是被减数）
input [3:0] alu_ctrl, //操作功能（加、减、与、或、异或等）
output [WIDTH-1:0] alu_res, //运算结果（和、差 …）
output alu_of //溢出标志of，加减法结果溢出时置1
);
    reg [WIDTH-1:0] yreg;
    reg ofreg;
    always @(*) begin
        yreg=0;
        ofreg=0;
        case (alu_ctrl)
            4'b0000:begin
                yreg=alu_op1+alu_op2;
                if((alu_op1[WIDTH-1]&alu_op2[WIDTH-1]&~yreg[WIDTH-1])|(~alu_op1[WIDTH-1]&~alu_op2[WIDTH-1]&yreg[WIDTH-1]))
                    ofreg=1;
            end
            4'b0001:begin
                yreg=alu_op1+~alu_op2+1;
                if((alu_op1[WIDTH-1]&~alu_op2[WIDTH-1]&~yreg[WIDTH-1])|(~alu_op1[WIDTH-1]&alu_op2[WIDTH-1]&yreg[WIDTH-1]))
                    ofreg=1;
            end
            4'b0010:begin
                if(alu_op1==alu_op2)
                    yreg=1;
            end
            4'b0011:begin
                if(alu_op1<alu_op2)
                    yreg=1;
            end
            4'b0100:begin
                if($signed(alu_op1)<$signed(alu_op2))
                    yreg=1;
            end
            4'b0101:begin
                yreg=alu_op1&alu_op2;
            end
            4'b0110:begin
                yreg=alu_op1|alu_op2;
            end
            4'b0111:begin
                yreg=alu_op1^alu_op2;
            end
            4'b1000:begin   //逻辑右移，移位位数为IMM[4:0]
                yreg=alu_op1>>alu_op2[4:0];
            end
            4'b1001:begin   //逻辑左移，移位位数为IMM[4:0]
                yreg=alu_op1<<alu_op2[4:0];
            end
            4'b1010:begin   //算数右移，移位位数为IMM[4:0]
                yreg=($signed(alu_op1))>>>alu_op2[4:0];
            end
            default:begin
                yreg=0;
                ofreg=0;
            end
        endcase
    end
    assign alu_res=yreg;
    assign alu_of=ofreg;
endmodule