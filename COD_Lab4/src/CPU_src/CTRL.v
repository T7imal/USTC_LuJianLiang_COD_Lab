module CTRL (
    input [31:0] inst,
    output reg jal,
    output reg jalr,
    output reg [2:0] br_type,
    output reg wb_en,
    output reg [1:0] wb_sel,
    output reg alu_op1_sel,
    output reg alu_op2_sel,
    output reg [3:0] alu_ctrl,
    output reg mem_we,
    output reg [2:0] imm_type
);
    always @(*) begin
        jal=0; jalr=0; br_type=0; wb_en=0;
        wb_sel=0; alu_op1_sel=0; alu_op2_sel=0;
        alu_ctrl=0; mem_we=0; imm_type=0;
        case (inst[6:0])
            7'b0010011:begin
                alu_op1_sel=0;
                alu_op2_sel=1;
                imm_type=1;
                wb_sel=0;
                wb_en=1;
                case (inst[14:12])
                    3'b111: alu_ctrl=4'b0000;   //addi
                    3'b001: alu_ctrl=4'b1001;   //slli
                    3'b101:begin
                        case (inst[31:25])
                            7'b0000000: alu_ctrl=4'b1000;   //srli
                            7'b0100000: alu_ctrl=4'b1010;   //srai
                        endcase
                    end    
                endcase
            end
            7'b0110011:begin
                alu_op1_sel=0;
                alu_op2_sel=0;
                wb_sel=0;
                wb_en=1;
                case (inst[14:12])
                    3'b000:begin
                        case (inst[31:25])
                            7'b0000000: alu_ctrl=4'b0000;   //add
                            7'b0100000: alu_ctrl=4'b0001;   //sub
                        endcase
                    end
                    3'b111: alu_ctrl=4'b0101;   //and
                    3'b110: alu_ctrl=4'b0110;   //or
                endcase
            end
            7'b0110111:begin
                alu_op2_sel=1;
                imm_type=4;
                wb_sel=3;
                wb_en=1;
                alu_ctrl=4'b0000;   //lui
            end
            7'b0010111:begin
                alu_op1_sel=1;
                alu_op2_sel=1;
                imm_type=4;
                wb_sel=0;
                wb_en=1;
                alu_ctrl=4'b0000;   //auipc
            end
            7'b1101111:begin
                jal=1;
                alu_op1_sel=1;
                alu_op2_sel=1;
                imm_type=5;
                wb_sel=1;
                wb_en=1;
                alu_ctrl=4'b0000;   //jal
            end
            7'b1100111:begin
                jalr=1;
                alu_op1_sel=0;
                alu_op2_sel=1;
                imm_type=1;
                wb_sel=1;
                wb_en=1;
                alu_ctrl=4'b0000;   //jalr
            end
            7'b1100011:begin
                alu_op1_sel=1;
                alu_op2_sel=1;
                imm_type=3;
                alu_ctrl=4'b0000;
                case (inst[14:12])
                    3'b000: br_type=1;  //beq
                    3'b001: br_type=2;  //bne
                    3'b100: br_type=3;  //blt
                    3'b101: br_type=4;  //bge
                    3'b110: br_type=5;  //bltu
                    3'b111: br_type=6;  //bgeu
                endcase
            end
            7'b0000011:begin
                case (inst[14:12])
                    3'b010:begin
                        alu_op1_sel=0;
                        alu_op2_sel=1;
                        imm_type=1;
                        alu_ctrl=4'b0000;
                        wb_sel=2;
                        wb_en=1;        //lw
                    end
                endcase
            end
            7'b0100011:begin
                case (inst[14:12])
                    3'b010:begin
                        alu_op1_sel=0;
                        alu_op2_sel=1;
                        imm_type=2;
                        alu_ctrl=4'b0000;
                        mem_we=1;       //sw
                    end
                endcase
            end
        endcase
    end
endmodule