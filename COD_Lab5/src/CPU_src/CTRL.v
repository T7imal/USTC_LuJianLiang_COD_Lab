module CTRL (
    input [31:0] inst,
    output reg jal,
    output reg jalr,
    output reg [1:0] br_type,
    output reg alu_src1_sel,
    output reg alu_src2_sel,
    output reg [3:0] alu_func,
    output reg mem_we,
    output reg [2:0] imm_type,
    output reg rf_re0,
    output reg rf_re1,
    output reg [1:0] rf_wd_sel,
    output reg rf_we
);
    always @(*) begin
        jal=0; jalr=0; br_type=0;
        alu_src1_sel=0; alu_src2_sel=0;
        alu_func=0; mem_we=0; imm_type=0;
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
                    3'b111: alu_func=4'b0000;   //addi
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
                        endcase
                    end
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
                    3'b100: br_type=2;  //blt
                endcase
            end
            7'b0000011:begin
                case (inst[14:12])
                    3'b010:begin
                        alu_src1_sel=0;
                        alu_src2_sel=1;
                        imm_type=1;
                        alu_func=4'b0000;
                        rf_wd_sel=2;
                        rf_we= (inst[11:7]==5'b00000) ? 0 : 1;
                        rf_re0= (inst[19:15]==5'b00000) ? 0 : 1;    //lw
                    end
                endcase
            end
            7'b0100011:begin
                case (inst[14:12])
                    3'b010:begin
                        alu_src1_sel=0;
                        alu_src2_sel=1;
                        imm_type=2;
                        alu_func=4'b0000;
                        rf_re0= (inst[19:15]==5'b00000) ? 0 : 1;
                        rf_re1= (inst[24:20]==5'b00000) ? 0 : 1;
                        mem_we=1;       //sw
                    end
                endcase
            end
        endcase
    end
endmodule