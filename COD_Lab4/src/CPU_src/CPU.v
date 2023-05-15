`timescale 1ns / 1ps


module CPU(
    input clk, 
    input rst,

    // MEM And MMIO Data BUS
    output [31:0] im_addr,
    input [31:0] im_dout,
    output [31:0] mem_addr,
    output  mem_we,		            
    output [31:0] mem_din,
    input [31:0] mem_dout,	        

    // Debug BUS with PDU
    output [31:0] current_pc, 	            // Current_pc
    output [31:0] next_pc,
    input [31:0] cpu_check_addr,	        // Check current datapath state (code)
    output [31:0] cpu_check_data            // Current datapath state data

);
    // Write your CPU here!
    wire [31:0] inst, mem_rd, pc_cur, alu_res, rd1, pc_next;
    assign inst=im_dout;
    assign mem_rd=mem_dout;
    assign im_addr=pc_cur;
    assign mem_addr=alu_res;
    assign mem_din=rd1;
    assign current_pc=pc_cur;
    assign next_pc=pc_next;
    wire [31:0] pc_add4, pc_jalr, rd0, wb_data, rd_dbg, alu_op1, alu_op2, imm, debug_check_data;
    wire [1:0] wb_sel;
    wire [2:0] imm_type, br_type;
    wire [3:0] alu_ctrl;
    wire jal, jalr, br, wb_en, alu_op1_sel, alu_op2_sel;
    assign cpu_check_data=
        cpu_check_addr[15:8]==8'h00 ? debug_check_data:
        cpu_check_addr[15:8]==8'h10 ? rd_dbg:
        0;

    PC pc(
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc_cur(pc_cur)
    );

    ADD add(
        .lhs(32'h4),
        .rhs(pc_cur),
        .res(pc_add4)
    );

    AND and_(
        .lhs(32'hFFFFFFFE),
        .rhs(alu_res),
        .res(pc_jalr)
    );

    Branch branch(
        .op1(rd0),
        .op2(rd1),
        .br_type(br_type),
        .br(br)
    );

    NPC_SEL npc_sel(
        .pc_add4(pc_add4),
        .pc_jal_br(alu_res),
        .pc_jalr(pc_jalr),
        .jal(jal),
        .jalr(jalr),
        .br(br),
        .pc_next(pc_next)
    );

    RF rf(
        .we(wb_en),
        .clk(clk),
        .ra0(inst[19:15]),
        .ra1(inst[24:20]),
        .wa(inst[11:7]),
        .wd(wb_data),
        .ra_dbg(cpu_check_addr[4:0]),
        .rd0(rd0),
        .rd1(rd1),
        .rd_dbg(rd_dbg)
    );

    MUX1 alu_sel1(
        .src0(rd0),
        .src1(pc_cur),
        .sel(alu_op1_sel),
        .res(alu_op1)
    );

    MUX1 alu_sel2(
        .src0(rd1),
        .src1(imm),
        .sel(alu_op2_sel),
        .res(alu_op2)
    );

    Immediate immediate(
        .inst(inst),
        .imm_type(imm_type),
        .imm(imm)
    );

    ALU alu(
        .alu_op1(alu_op1),
        .alu_op2(alu_op2),
        .alu_ctrl(alu_ctrl),
        .alu_res(alu_res)
    );

    MUX2 reg_write_sel(
        .src0(alu_res),
        .src1(pc_add4),
        .src2(mem_rd),
        .src3(imm),
        .sel(wb_sel),
        .res(wb_data)
    );

    CTRL ctrl(
        .inst(inst),
        .jal(jal),
        .jalr(jalr),
        .br_type(br_type),
        .wb_en(wb_en),
        .wb_sel(wb_sel),
        .alu_op1_sel(alu_op1_sel),
        .alu_op2_sel(alu_op2_sel),
        .alu_ctrl(alu_ctrl),
        .imm_type(imm_type),
        .mem_we(mem_we)
    );

    CHECK_DATA_SEL check_data_sel(
        .pc_in(pc_next),
        .pc_out(pc_cur),
        .instruction(inst),
        .rf_ra0(inst[19:15]),
        .rf_ra1(inst[24:20]),
        .rf_rd0(rd0),
        .rf_rd1(rd1),
        .rf_wa(inst[11:7]),
        .rf_wd(wb_data),
        .rf_we(wb_en),
        .imm(imm),
        .alu_sr1(alu_op1),
        .alu_sr2(alu_op2),
        .alu_func(alu_ctrl),
        .alu_ans(alu_res),
        .pc_jalr(pc_jalr),
        .dm_addr(alu_res),
        .dm_din(mem_din),
        .dm_dout(mem_rd),
        .dm_we(mem_we),
        .check_addr(cpu_check_addr),
        .check_data(debug_check_data)
    );

endmodule