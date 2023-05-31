module SEG_REG (
    input clk,
    input flush,
    input stall,
    input [31:0] pc_cur_in,
    input [31:0] inst_in,
    input [4:0] rf_ra0_in,
    input [4:0] rf_ra1_in,
    input rf_re0_in,
    input rf_re1_in,
    input [31:0] rf_rd0_raw_in,
    input [31:0] rf_rd1_raw_in,
    input [31:0] rf_rd0_in,
    input [31:0] rf_rd1_in,
    input [4:0] rf_wa_in,
    input [1:0] rf_wd_sel_in,
    input rf_we_in,
    input [2:0] imm_type_in,
    input [31:0] imm_in,
    input alu_src1_sel_in,
    input alu_src2_sel_in,
    input [31:0] alu_src1_in,
    input [31:0] alu_src2_in,
    input [3:0] alu_func_in,
    input [31:0] alu_ans_in,
    input [31:0] pc_add4_in,
    input [31:0] pc_br_in,
    input [31:0] pc_jal_in,
    input [31:0] pc_jalr_in,
    input jal_in,
    input jalr_in,
    input [1:0] br_type_in,
    input br_in,
    input [1:0] pc_sel_in,
    input [31:0] pc_next_in,
    input [31:0] dm_addr_in,
    input [31:0] dm_din_in,
    input [31:0] dm_dout_in,
    input dm_we_in,
    output [31:0] pc_cur_out,
    output [31:0] inst_out,
    output [4:0] rf_ra0_out,
    output [4:0] rf_ra1_out,
    output rf_re0_out,
    output rf_re1_out,
    output [31:0] rf_rd0_raw_out,
    output [31:0] rf_rd1_raw_out,
    output [31:0] rf_rd0_out,
    output [31:0] rf_rd1_out,
    output [4:0] rf_wa_out,
    output [1:0] rf_wd_sel_out,
    output rf_we_out,
    output [2:0] imm_type_out,
    output [31:0] imm_out,
    output alu_src1_sel_out,
    output alu_src2_sel_out,
    output [31:0] alu_src1_out,
    output [31:0] alu_src2_out,
    output [3:0] alu_func_out,
    output [31:0] alu_ans_out,
    output [31:0] pc_add4_out,
    output [31:0] pc_br_out,
    output [31:0] pc_jal_out,
    output [31:0] pc_jalr_out,
    output jal_out,
    output jalr_out,
    output [1:0] br_type_out,
    output br_out,
    output [1:0] pc_sel_out,
    output [31:0] pc_next_out,
    output [31:0] dm_addr_out,
    output [31:0] dm_din_out,
    output [31:0] dm_dout_out,
    output dm_we_out
);
    reg [31:0] pc_cur;
    reg [31:0] inst;
    reg [4:0] rf_ra0;
    reg [4:0] rf_ra1;
    reg rf_re0;
    reg rf_re1;
    reg [31:0] rf_rd0_raw;
    reg [31:0] rf_rd1_raw;
    reg [31:0] rf_rd0;
    reg [31:0] rf_rd1;
    reg [4:0] rf_wa;
    reg [1:0] rf_wd_sel;
    reg rf_we;
    reg [2:0] imm_type;
    reg [31:0] imm;
    reg alu_src1_sel;
    reg alu_src2_sel;
    reg [31:0] alu_src1;
    reg [31:0] alu_src2;
    reg [3:0] alu_func;
    reg [31:0] alu_ans;
    reg [31:0] pc_add4;
    reg [31:0] pc_br;
    reg [31:0] pc_jal;
    reg [31:0] pc_jalr;
    reg jal;
    reg jalr;
    reg [1:0] br_type;
    reg br;
    reg [1:0] pc_sel;
    reg [31:0] pc_next;
    reg [31:0] dm_addr;
    reg [31:0] dm_din;
    reg [31:0] dm_dout;
    reg dm_we;
    always @(posedge clk) begin
        if(stall)begin
        end
        else if(flush)begin
            pc_cur <= 0;
            inst <= 0;
            rf_ra0 <= 0;
            rf_ra1 <= 0;
            rf_re0 <= 0;
            rf_re1 <= 0;
            rf_rd0_raw <= 0;
            rf_rd1_raw <= 0;
            rf_rd0 <= 0;
            rf_rd1 <= 0;
            rf_wa <= 0;
            rf_wd_sel <= 0;
            rf_we <= 0;
            imm_type <= 0;
            imm <= 0;
            alu_src1_sel <= 0;
            alu_src2_sel <= 0;
            alu_src1 <= 0;
            alu_src2 <= 0;
            alu_func <= 0;
            alu_ans <= 0;
            pc_add4 <= 0;
            pc_br <= 0;
            pc_jal <= 0;
            pc_jalr <= 0;
            jal <= 0;
            jalr <= 0;
            br_type <= 0;
            br <= 0;
            pc_sel <= 0;
            pc_next <= 0;
            dm_addr <= 0;
            dm_din <= 0;
            dm_dout <= 0;
            dm_we <= 0;
        end
        else begin
            pc_cur <= pc_cur_in;
            inst <= inst_in;
            rf_ra0 <= rf_ra0_in;
            rf_ra1 <= rf_ra1_in;
            rf_re0 <= rf_re0_in;
            rf_re1 <= rf_re1_in;
            rf_rd0_raw <= rf_rd0_raw_in;
            rf_rd1_raw <= rf_rd1_raw_in;
            rf_rd0 <= rf_rd0_in;
            rf_rd1 <= rf_rd1_in;
            rf_wa <= rf_wa_in;
            rf_wd_sel <= rf_wd_sel_in;
            rf_we <= rf_we_in;
            imm_type <= imm_type_in;
            imm <= imm_in;
            alu_src1_sel <= alu_src1_sel_in;
            alu_src2_sel <= alu_src2_sel_in;
            alu_src1 <= alu_src1_in;
            alu_src2 <= alu_src2_in;
            alu_func <= alu_func_in;
            alu_ans <= alu_ans_in;
            pc_add4 <= pc_add4_in;
            pc_br <= pc_br_in;
            pc_jal <= pc_jal_in;
            pc_jalr <= pc_jalr_in;
            jal <= jal_in;
            jalr <= jalr_in;
            br_type <= br_type_in;
            br <= br_in;
            pc_sel <= pc_sel_in;
            pc_next <= pc_next_in;
            dm_addr <= dm_addr_in;
            dm_din <= dm_din_in;
            dm_dout <= dm_dout_in;
            dm_we <= dm_we_in;
        end
    end
    assign pc_cur_out = pc_cur;
    assign inst_out = inst;
    assign rf_ra0_out = rf_ra0;
    assign rf_ra1_out = rf_ra1;
    assign rf_re0_out = rf_re0;
    assign rf_re1_out = rf_re1;
    assign rf_rd0_raw_out = rf_rd0_raw;
    assign rf_rd1_raw_out = rf_rd1_raw;
    assign rf_rd0_out = rf_rd0;
    assign rf_rd1_out = rf_rd1;
    assign rf_wa_out = rf_wa;
    assign rf_wd_sel_out = rf_wd_sel;
    assign rf_we_out = rf_we;
    assign imm_type_out = imm_type;
    assign imm_out = imm;
    assign alu_src1_sel_out = alu_src1_sel;
    assign alu_src2_sel_out = alu_src2_sel;
    assign alu_src1_out = alu_src1;
    assign alu_src2_out = alu_src2;
    assign alu_func_out = alu_func;
    assign alu_ans_out = alu_ans;
    assign pc_add4_out = pc_add4;
    assign pc_br_out = pc_br;
    assign pc_jal_out = pc_jal;
    assign pc_jalr_out = pc_jalr;
    assign jal_out = jal;
    assign jalr_out = jalr;
    assign br_type_out = br_type;
    assign br_out = br;
    assign pc_sel_out = pc_sel;
    assign pc_next_out = pc_next;
    assign dm_addr_out = dm_addr;
    assign dm_din_out = dm_din;
    assign dm_dout_out = dm_dout;
    assign dm_we_out = dm_we;
endmodule