/*
 *   "RV32-I 除系统指令外的全部 37 条指令如下
 *  必做部分(10) add、addi、auipc、lui、lw、sw、beq、blt、jal、jalr
 *  算数与逻辑指令(13) sll、slli、srl、srli、sra、srai、sub、xor、xori、or、ori、and、andi
 *  分支与条件指令(8) bne、bge、bltu、bgeu、 slt、slti、slti、sltiu
 *  访存指令(6) lb、lh、lbu、lhu、sb、sh"
 */

module CTRL (
    input [31:0] inst,
    output reg jal,
    output reg jalr,
    output reg [2:0] br_type,
    output reg alu_src1_sel,
    output reg alu_src2_sel,
    output reg [3:0] alu_func,
    output reg mem_we,
    output reg [2:0] imm_type,
    output reg rf_re0,
    output reg rf_re1,
    output reg [1:0] rf_wd_sel,
    output reg rf_we,
    output reg [2:0] load_type,
    output reg [1:0] store_type
);
    always @(*) begin
        jal=0; jalr=0; br_type=0;
        alu_src1_sel=0; alu_src2_sel=0;
        alu_func=0; mem_we=0; imm_type=0; load_type=0; store_type=0;
        rf_re0=0;rf_re1=0;rf_wd_sel=0;rf_we=0;
        case (inst[6:0])
            7'b0010011:begin
                alu_src1_sel=0;
                alu_src2_sel=1;
                imm_type=1;
                rf_wd_sel=0;
                rf_we= (inst[11:7]==5'b00000) ? 0 : 1;
                rf_re0= (inst[19:15]==5'b00000) ? 0 : 1;
                case (inst[14:12])
                    3'b000: alu_func=4'b0000;   //addi
                    3'b001: alu_func=4'b1001;   //slli
                    3'b010: alu_func=4'b0100;   //slti
                    3'b011: alu_func=4'b0011;   //sltiu
                    3'b100: alu_func=4'b0111;   //xori
                    3'b101:begin
                        case (inst[31:25])
                            7'b0000000: alu_func=4'b1000;   //srli
                            7'b0100000: alu_func=4'b1010;   //srai
                        endcase
                    end  
                    3'b110: alu_func=4'b0110;   //ori
                    3'b111: alu_func=4'b0101;   //andi  
                endcase
            end
            7'b0110011:begin
                alu_src1_sel=0;
                alu_src2_sel=0;
                rf_wd_sel=0;
                rf_we= (inst[11:7]==5'b00000) ? 0 : 1;
                rf_re0= (inst[19:15]==5'b00000) ? 0 : 1;
                rf_re1= (inst[24:20]==5'b00000) ? 0 : 1;
                case (inst[14:12])
                    3'b000:begin
                        case (inst[31:25])
                            7'b0000000: alu_func=4'b0000;   //add
                            7'b0100000: alu_func=4'b0001;   //sub
                        endcase
                    end
                    3'b001: alu_func=4'b1001;   //sll
                    3'b010: alu_func=4'b0100;   //slt
                    3'b011: alu_func=4'b0011;   //sltu
                    3'b100: alu_func=4'b0111;   //xor
                    3'b101:begin
                        case (inst[31:25])
                            7'b0000000: alu_func=4'b1000;   //srl
                            7'b0100000: alu_func=4'b1010;   //sra
                        endcase
                    end
                    3'b110: alu_func=4'b0110;   //or
                    3'b111: alu_func=4'b0101;   //and
                    
                endcase
            end
            7'b0110111:begin
                alu_src2_sel=1;
                imm_type=4;
                rf_wd_sel=3;
                rf_we= (inst[11:7]==5'b00000) ? 0 : 1;
                alu_func=4'b0000;   //lui
            end
            7'b0010111:begin
                alu_src1_sel=1;
                alu_src2_sel=1;
                imm_type=4;
                rf_wd_sel=0;
                rf_we= (inst[11:7]==5'b00000) ? 0 : 1;
                alu_func=4'b0000;   //auipc
            end
            7'b1101111:begin
                jal=1;
                alu_src1_sel=1;
                alu_src2_sel=1;
                imm_type=5;
                rf_wd_sel=1;
                rf_we= (inst[11:7]==5'b00000) ? 0 : 1;
                alu_func=4'b0000;   //jal
            end
            7'b1100111:begin
                jalr=1;
                alu_src1_sel=0;
                alu_src2_sel=1;
                imm_type=1;
                rf_wd_sel=1;
                rf_we= (inst[11:7]==5'b00000) ? 0 : 1;
                rf_re0= (inst[19:15]==5'b00000) ? 0 : 1;
                alu_func=4'b0000;   //jalr
            end
            7'b1100011:begin
                alu_src1_sel=1;
                alu_src2_sel=1;
                imm_type=3;
                alu_func=4'b0000;
                rf_re0= (inst[19:15]==5'b00000) ? 0 : 1;
                rf_re1= (inst[24:20]==5'b00000) ? 0 : 1;
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
                alu_src1_sel=0;
                alu_src2_sel=1;
                imm_type=1;
                alu_func=4'b0000;
                rf_wd_sel=2;
                rf_we= (inst[11:7]==5'b00000) ? 0 : 1;
                rf_re0= (inst[19:15]==5'b00000) ? 0 : 1;
                case (inst[14:12])
                    3'b000: load_type=1;    //lb
                    3'b001: load_type=2;    //lh
                    3'b010: load_type=3;    //lw
                    3'b100: load_type=4;    //lbu
                    3'b101: load_type=5;    //lhu
                endcase
            end
            7'b0100011:begin
                alu_src1_sel=0;
                alu_src2_sel=1;
                imm_type=2;
                alu_func=4'b0000;
                rf_re0= (inst[19:15]==5'b00000) ? 0 : 1;
                rf_re1= (inst[24:20]==5'b00000) ? 0 : 1;
                mem_we=1;
                case (inst[14:12])
                    3'b000: store_type=1;   //sb
                    3'b001: store_type=2;   //sh
                    3'b010: store_type=3;   //sw
                endcase
            end
        endcase
    end
endmodule