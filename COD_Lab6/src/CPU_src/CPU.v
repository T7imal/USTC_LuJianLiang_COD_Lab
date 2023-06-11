`timescale 1ns / 1ps

/* 
 *   Author: YOU
 *   Last update: 2023.04.20
 */

module CPU(
    input clk, 
    input rst,

    // MEM And MMIO Data BUS
    output [31:0] im_addr,      // Instruction address (The same as current PC)
    input [31:0] im_dout,       // Instruction data (Current instruction)
    output [31:0] mem_addr,     // Memory read/write address
    output mem_we,              // Memory writing enable		            
    output [31:0] mem_din,      // Data ready to write to memory
    input [31:0] mem_dout,	    // Data read from memory

    // Debug BUS with PDU
    output [31:0] current_pc, 	        // Current_pc, pc_out
    output [31:0] next_pc,              // Next_pc, pc_in    
    input [31:0] cpu_check_addr,	    // Check current datapath state (code)
    output [31:0] cpu_check_data    // Current datapath state data
);
    
    
    // Write your CPU here!
    // You might need to write these modules:
    //   dm_dout   ALU、RF、Control、Add(Or just add-mode ALU)、And(Or just and-mode ALU)、PCReg、Imm、Branch、Mux�?...
    wire [31:0] pc_next, inst_raw, dm_dout, check_data_hzd, check_data, jump_addr, jalr_addr;
    wire [1:0] top_fix;
    wire br_pre, br_pre_global, br_pre_partical, gp_sel, hit, pre_failure, jalr_stack_rst;
    //IF
    wire [31:0] pc_cur_if, pc_add4_if, inst_if, rf_rd0_fd, rf_rd1_fd, check_data_if;
    wire stall_if, flush_if;
    //ID
    wire [31:0] pc_cur_id, inst_id, rf_rd0_raw_id, rf_rd1_raw_id, pc_add4_id, imm_id, rf_rd_dbg_id, check_data_id, jal_addr_id;
    wire [4:0] rf_ra0_id, rf_ra1_id, rf_wa_id;
    wire [3:0] alu_func_id;
    wire [2:0] imm_type_id, load_type_id, br_type_id;
    wire [1:0] rf_wd_sel_id, store_type_id;
    wire stall_id, flush_id, rf_re0_id, rf_re1_id, rf_we_id, alu_src1_sel_id, alu_src2_sel_id, jal_id, jalr_id, dm_we_id;
    //EX
    wire [31:0] pc_cur_ex, inst_ex, rf_rd0_raw_ex, rf_rd1_raw_ex, rf_rd0_ex, rf_rd1_ex, pc_add4_ex, imm_ex, alu_src1_ex, alu_src2_ex, alu_ans_ex, pc_jalr_ex, check_data_ex;
    wire [4:0] rf_ra0_ex, rf_ra1_ex, rf_wa_ex;
    wire [3:0] alu_func_ex;
    wire [2:0] imm_type_ex, load_type_ex, br_type_ex;
    wire [1:0] rf_wd_sel_ex, pc_sel_ex, store_type_ex;
    wire stall_ex, flush_ex, rf_re0_ex, rf_re1_ex, rf_we_ex, alu_src1_sel_ex, alu_src2_sel_ex, jal_ex, jalr_ex, br_ex, dm_we_ex;
    //MEM
    wire [31:0] pc_cur_mem, inst_mem, rf_rd0_raw_mem, rf_rd1_raw_mem, rf_rd0_mem, rf_rd1_mem, pc_add4_mem, pc_br_mem, imm_mem, alu_src1_mem, alu_src2_mem, alu_ans_mem, pc_jal_mem, pc_jalr_mem, pc_next_mem, dm_addr_mem, dm_din_mem, store_data, check_data_mem;
    wire [4:0] rf_ra0_mem, rf_ra1_mem, rf_wa_mem;
    wire [3:0] alu_func_mem;
    wire [2:0] imm_type_mem, load_type_mem, br_type_mem;
    wire [1:0] rf_wd_sel_mem, pc_sel_mem, store_type_mem;
    wire flush_mem, rf_re0_mem, rf_re1_mem, rf_we_mem, alu_src1_sel_mem, alu_src2_sel_mem, jal_mem, jalr_mem, br_mem, dm_we_mem;
    //WB
    wire [31:0] pc_cur_wb, inst_wb, rf_rd0_raw_wb, rf_rd1_raw_wb, rf_rd0_wb, rf_rd1_wb, rf_wd_wb, pc_add4_wb, pc_br_wb, imm_wb, alu_src1_wb, alu_src2_wb, alu_ans_wb, pc_jal_wb, pc_jalr_wb, pc_next_wb, dm_addr_wb, dm_din_wb, dm_dout_wb, load_data_wb, check_data_wb;
    wire [4:0] rf_ra0_wb, rf_ra1_wb, rf_wa_wb;
    wire [3:0] alu_func_wb;
    wire [2:0] imm_type_wb, load_type_wb, br_type_wb;
    wire [1:0] rf_wd_sel_wb, pc_sel_wb, store_type_wb;
    wire rf_re0_wb, rf_re1_wb, rf_we_wb, alu_src1_sel_wb, alu_src2_sel_wb, jal_wb, jalr_wb, br_wb, dm_we_wb;

    assign inst_raw=im_dout;
    assign dm_dout=mem_dout;
    assign im_addr=pc_cur_if;
    assign mem_addr=alu_ans_mem;
    assign mem_din=store_data;
    assign mem_we=dm_we_mem;
    assign current_pc=pc_cur_if;
    assign next_pc=pc_next;

    ADD add(
        .rhs(pc_cur_if),
        .lhs(32'h4),
        .res(pc_add4_if)
    );

    PC pc(
        .pc_next(pc_next),
        .pc_cur(pc_cur_if),
        .clk(clk),
        .stall(stall_if)
    );

    Mux1 inst_flush(
        .src0(inst_raw),
        .src1(32'h00000033),
        .res(inst_if),
        .sel(flush_if)
    );

    SEG_REG seg_reg_if_id(
        .clk(clk),
        .flush(flush_id),
        .stall(stall_id),
        .pc_cur_in(pc_cur_if),
        .inst_in(inst_if),
        .rf_ra0_in(inst_if[19:15]),
        .rf_ra1_in(inst_if[24:20]),
        .rf_re0_in(1'h0),
        .rf_re1_in(1'h0),
        .rf_rd0_raw_in(32'h0),
        .rf_rd1_raw_in(32'h0),
        .rf_rd0_in(32'h0),
        .rf_rd1_in(32'h0),
        .rf_wa_in(inst_if[11:7]),
        .rf_wd_sel_in(2'h0),
        .rf_we_in(1'h0),
        .imm_type_in(3'h0),
        .imm_in(32'h0),
        .alu_src1_sel_in(1'h0),
        .alu_src2_sel_in(1'h0),
        .alu_src1_in(32'h0),
        .alu_src2_in(32'h0),
        .alu_func_in(4'h0),
        .alu_ans_in(32'h0),
        .pc_add4_in(pc_add4_if),
        .pc_br_in(32'h0),
        .pc_jal_in(32'h0),
        .pc_jalr_in(32'h0),
        .jal_in(1'h0),
        .jalr_in(1'h0),
        .br_type_in(3'h0),
        .br_in(1'h0),
        .pc_sel_in(2'h0),
        .pc_next_in(32'h0),
        .dm_addr_in(32'h0),
        .dm_din_in(32'h0),
        .dm_dout_in(32'h0),
        .dm_we_in(1'h0),
        .pc_cur_out(pc_cur_id),
        .inst_out(inst_id),
        .rf_ra0_out(rf_ra0_id),
        .rf_ra1_out(rf_ra1_id),
        .rf_re0_out(),
        .rf_re1_out(),
        .rf_rd0_raw_out(),
        .rf_rd1_raw_out(),
        .rf_rd0_out(),
        .rf_rd1_out(),
        .rf_wa_out(rf_wa_id),
        .rf_wd_sel_out(),
        .rf_we_out(),
        .imm_type_out(),
        .imm_out(),
        .alu_src1_sel_out(),
        .alu_src2_sel_out(),
        .alu_src1_out(),
        .alu_src2_out(),
        .alu_func_out(),
        .alu_ans_out(),
        .pc_add4_out(pc_add4_id),
        .pc_br_out(),
        .pc_jal_out(),
        .pc_jalr_out(),
        .jal_out(),
        .jalr_out(),
        .br_type_out(),
        .br_out(),
        .pc_sel_out(),
        .pc_next_out(),
        .dm_addr_out(),
        .dm_din_out(),
        .dm_dout_out(),
        .dm_we_out(),
        .load_type_in(3'h0),
        .store_type_in(2'h0),
        .load_type_out(),
        .store_type_out()
    );

    RF rf(
        .ra0(rf_ra0_id),
        .ra1(rf_ra1_id),
        .wa(rf_wa_wb),
        .wd(rf_wd_wb),
        .ra_dbg(cpu_check_addr[4:0]),
        .rd0(rf_rd0_raw_id),
        .rd1(rf_rd1_raw_id),
        .rd_dbg(rf_rd_dbg_id),
        .we(rf_we_wb),
        .clk(clk)
    );

    Immediate immediate(
        .inst(inst_id),
        .imm(imm_id),
        .imm_type(imm_type_id)
    );

    CTRL ctrl(
        .inst(inst_id),
        .rf_re0(rf_re0_id),
        .rf_re1(rf_re1_id),
        .rf_wd_sel(rf_wd_sel_id),
        .rf_we(rf_we_id),
        .imm_type(imm_type_id),
        .alu_src1_sel(alu_src1_sel_id),
        .alu_src2_sel(alu_src2_sel_id),
        .alu_func(alu_func_id),
        .jal(jal_id),
        .jalr(jalr_id),
        .br_type(br_type_id),
        .mem_we(dm_we_id),
        .load_type(load_type_id),
        .store_type(store_type_id)
    );

    SEG_REG seg_reg_id_ex(
        .clk(clk),
        .flush(flush_ex),
        .stall(stall_ex),
        .pc_cur_in(pc_cur_id),
        .inst_in(inst_id),
        .rf_ra0_in(rf_ra0_id),
        .rf_ra1_in(rf_ra1_id),
        .rf_re0_in(rf_re0_id),
        .rf_re1_in(rf_re1_id),
        .rf_rd0_raw_in(rf_rd0_raw_id),
        .rf_rd1_raw_in(rf_rd1_raw_id),
        .rf_rd0_in(32'h0),
        .rf_rd1_in(32'h0),
        .rf_wa_in(rf_wa_id),
        .rf_wd_sel_in(rf_wd_sel_id),
        .rf_we_in(rf_we_id),
        .imm_type_in(imm_type_id),
        .imm_in(imm_id),
        .alu_src1_sel_in(alu_src1_sel_id),
        .alu_src2_sel_in(alu_src2_sel_id),
        .alu_src1_in(32'h0),
        .alu_src2_in(32'h0),
        .alu_func_in(alu_func_id),
        .alu_ans_in(32'h0),
        .pc_add4_in(pc_add4_id),
        .pc_br_in(32'h0),
        .pc_jal_in(32'h0),
        .pc_jalr_in(32'h0),
        .jal_in(jal_id),
        .jalr_in(jalr_id),
        .br_type_in(br_type_id),
        .br_in(1'h0),
        .pc_sel_in(2'h0),
        .pc_next_in(32'h0),
        .dm_addr_in(32'h0),
        .dm_din_in(32'h0),
        .dm_dout_in(32'h0),
        .dm_we_in(dm_we_id),
        .pc_cur_out(pc_cur_ex),
        .inst_out(inst_ex),
        .rf_ra0_out(rf_ra0_ex),
        .rf_ra1_out(rf_ra1_ex),
        .rf_re0_out(rf_re0_ex),
        .rf_re1_out(rf_re1_ex),
        .rf_rd0_raw_out(rf_rd0_raw_ex),
        .rf_rd1_raw_out(rf_rd1_raw_ex),
        .rf_rd0_out(),
        .rf_rd1_out(),
        .rf_wa_out(rf_wa_ex),
        .rf_wd_sel_out(rf_wd_sel_ex),
        .rf_we_out(rf_we_ex),
        .imm_type_out(imm_type_ex),
        .imm_out(imm_ex),
        .alu_src1_sel_out(alu_src1_sel_ex),
        .alu_src2_sel_out(alu_src2_sel_ex),
        .alu_src1_out(),
        .alu_src2_out(),
        .alu_func_out(alu_func_ex),
        .alu_ans_out(),
        .pc_add4_out(pc_add4_ex),
        .pc_br_out(),
        .pc_jal_out(),
        .pc_jalr_out(),
        .jal_out(jal_ex),
        .jalr_out(jalr_ex),
        .br_type_out(br_type_ex),
        .br_out(),
        .pc_sel_out(),
        .pc_next_out(),
        .dm_addr_out(),
        .dm_din_out(),
        .dm_dout_out(),
        .dm_we_out(dm_we_ex),
        .load_type_in(load_type_id),
        .store_type_in(store_type_id),
        .load_type_out(load_type_ex),
        .store_type_out(store_type_ex)
    );

    AND and_(
        .lhs(32'hFFFFFFFE),
        .rhs(alu_ans_ex),
        .res(pc_jalr_ex)
    );

    Mux1 alu_sel1(
        .src0(rf_rd0_ex),
        .src1(pc_cur_ex),
        .res(alu_src1_ex),
        .sel(alu_src1_sel_ex)
    );

    Mux1 alu_sel2(
        .src0(rf_rd1_ex),
        .src1(imm_ex),
        .res(alu_src2_ex),
        .sel(alu_src2_sel_ex)
    );

    ALU alu(
        .alu_src1(alu_src1_ex),
        .alu_src2(alu_src2_ex),
        .alu_ans(alu_ans_ex),
        .alu_func(alu_func_ex),
        .alu_of()
    );

    Branch branch(
        .op1(rf_rd0_ex),
        .op2(rf_rd1_ex),
        .br(br_ex),
        .br_type(br_type_ex)
    );

    Encoder pc_sel_gen(
        .jal(jal_ex),
        .jalr(jalr_ex),
        .br(br_ex),
        .pc_sel(pc_sel_ex)
    );
    Mux1 rf_rd0_fwd(
        .src0(rf_rd0_raw_ex),
        .src1(rf_rd0_fd),
        .res(rf_rd0_ex),
        .sel(rf_rd0_fe)
    );

    Mux1 rf_rd1_fwd(
        .src0(rf_rd1_raw_ex),
        .src1(rf_rd1_fd),
        .res(rf_rd1_ex),
        .sel(rf_rd1_fe)
    );

    SEG_REG seg_reg_ex_mem(
        .clk(clk),
        .flush(flush_mem),
        .stall(1'h0),
        .pc_cur_in(pc_cur_ex),
        .inst_in(inst_ex),
        .rf_ra0_in(rf_ra0_ex),
        .rf_ra1_in(rf_ra1_ex),
        .rf_re0_in(rf_re0_ex),
        .rf_re1_in(rf_re1_ex),
        .rf_rd0_raw_in(rf_rd0_raw_ex),
        .rf_rd1_raw_in(rf_rd1_raw_ex),
        .rf_rd0_in(rf_rd0_ex),
        .rf_rd1_in(rf_rd1_ex),
        .rf_wa_in(rf_wa_ex),
        .rf_wd_sel_in(rf_wd_sel_ex),
        .rf_we_in(rf_we_ex),
        .imm_type_in(imm_type_ex),
        .imm_in(imm_ex),
        .alu_src1_sel_in(alu_src1_sel_ex),
        .alu_src2_sel_in(alu_src2_sel_ex),
        .alu_src1_in(alu_src1_ex),
        .alu_src2_in(alu_src2_ex),
        .alu_func_in(alu_func_ex),
        .alu_ans_in(alu_ans_ex),
        .pc_add4_in(pc_add4_ex),
        .pc_br_in(alu_ans_ex),
        .pc_jal_in(alu_ans_ex),
        .pc_jalr_in(pc_jalr_ex),
        .jal_in(jal_ex),
        .jalr_in(jalr_ex),
        .br_type_in(br_type_ex),
        .br_in(br_ex),
        .pc_sel_in(pc_sel_ex),
        .pc_next_in(pc_next),
        .dm_addr_in(alu_ans_ex),
        .dm_din_in(rf_rd1_ex),
        .dm_dout_in(32'h0),
        .dm_we_in(dm_we_ex),
        .pc_cur_out(pc_cur_mem),
        .inst_out(inst_mem),
        .rf_ra0_out(rf_ra0_mem),
        .rf_ra1_out(rf_ra1_mem),
        .rf_re0_out(rf_re0_mem),
        .rf_re1_out(rf_re1_mem),
        .rf_rd0_raw_out(rf_rd0_raw_mem),
        .rf_rd1_raw_out(rf_rd1_raw_mem),
        .rf_rd0_out(rf_rd0_mem),
        .rf_rd1_out(rf_rd1_mem),
        .rf_wa_out(rf_wa_mem),
        .rf_wd_sel_out(rf_wd_sel_mem),
        .rf_we_out(rf_we_mem),
        .imm_type_out(imm_type_mem),
        .imm_out(imm_mem),
        .alu_src1_sel_out(alu_src1_sel_mem),
        .alu_src2_sel_out(alu_src2_sel_mem),
        .alu_src1_out(alu_src1_mem),
        .alu_src2_out(alu_src2_mem),
        .alu_func_out(alu_func_mem),
        .alu_ans_out(alu_ans_mem),
        .pc_add4_out(pc_add4_mem),
        .pc_br_out(pc_br_mem),
        .pc_jal_out(pc_jal_mem),
        .pc_jalr_out(pc_jalr_mem),
        .jal_out(jal_mem),
        .jalr_out(jalr_mem),
        .br_type_out(br_type_mem),
        .br_out(br_mem),
        .pc_sel_out(pc_sel_mem),
        .pc_next_out(pc_next_mem),
        .dm_addr_out(dm_addr_mem),
        .dm_din_out(dm_din_mem),
        .dm_dout_out(),
        .dm_we_out(dm_we_mem),
        .load_type_in(load_type_ex),
        .store_type_in(store_type_ex),
        .load_type_out(load_type_mem),
        .store_type_out(store_type_mem)
    );

    Store store(
        .dm_din(dm_din_mem),
        .dm_dout(dm_dout),
        .store_type(store_type_mem),
        .store_data(store_data)
    );

    SEG_REG seg_reg_mem_wb(
        .clk(clk),
        .flush(1'h0),
        .stall(1'h0),
        .pc_cur_in(pc_cur_mem),
        .inst_in(inst_mem),
        .rf_ra0_in(rf_ra0_mem),
        .rf_ra1_in(rf_ra1_mem),
        .rf_re0_in(rf_re0_mem),
        .rf_re1_in(rf_re1_mem),
        .rf_rd0_raw_in(rf_rd0_raw_mem),
        .rf_rd1_raw_in(rf_rd1_raw_mem),
        .rf_rd0_in(rf_rd0_mem),
        .rf_rd1_in(rf_rd1_mem),
        .rf_wa_in(rf_wa_mem),
        .rf_wd_sel_in(rf_wd_sel_mem),
        .rf_we_in(rf_we_mem),
        .imm_type_in(imm_type_mem),
        .imm_in(imm_mem),
        .alu_src1_sel_in(alu_src1_sel_mem),
        .alu_src2_sel_in(alu_src2_sel_mem),
        .alu_src1_in(alu_src1_mem),
        .alu_src2_in(alu_src2_mem),
        .alu_func_in(alu_func_mem),
        .alu_ans_in(alu_ans_mem),
        .pc_add4_in(pc_add4_mem),
        .pc_br_in(pc_br_mem),
        .pc_jal_in(pc_jal_mem),
        .pc_jalr_in(pc_jalr_mem),
        .jal_in(jal_mem),
        .jalr_in(jalr_mem),
        .br_type_in(br_type_mem),
        .br_in(br_mem),
        .pc_sel_in(pc_sel_mem),
        .pc_next_in(pc_next_mem),
        .dm_addr_in(dm_addr_mem),
        .dm_din_in(store_data),
        .dm_dout_in(dm_dout),
        .dm_we_in(dm_we_mem),
        .pc_cur_out(pc_cur_wb),
        .inst_out(inst_wb),
        .rf_ra0_out(rf_ra0_wb),
        .rf_ra1_out(rf_ra1_wb),
        .rf_re0_out(rf_re0_wb),
        .rf_re1_out(rf_re1_wb),
        .rf_rd0_raw_out(rf_rd0_raw_wb),
        .rf_rd1_raw_out(rf_rd1_raw_wb),
        .rf_rd0_out(rf_rd0_wb),
        .rf_rd1_out(rf_rd1_wb),
        .rf_wa_out(rf_wa_wb),
        .rf_wd_sel_out(rf_wd_sel_wb),
        .rf_we_out(rf_we_wb),
        .imm_type_out(imm_type_wb),
        .imm_out(imm_wb),
        .alu_src1_sel_out(alu_src1_sel_wb),
        .alu_src2_sel_out(alu_src2_sel_wb),
        .alu_src1_out(alu_src1_wb),
        .alu_src2_out(alu_src2_wb),
        .alu_func_out(alu_func_wb),
        .alu_ans_out(alu_ans_wb),
        .pc_add4_out(pc_add4_wb),
        .pc_br_out(pc_br_wb),
        .pc_jal_out(pc_jal_wb),
        .pc_jalr_out(pc_jalr_wb),
        .jal_out(jal_wb),
        .jalr_out(jalr_wb),
        .br_type_out(br_type_wb),
        .br_out(br_wb),
        .pc_sel_out(pc_sel_wb),
        .pc_next_out(pc_next_wb),
        .dm_addr_out(dm_addr_wb),
        .dm_din_out(dm_din_wb),
        .dm_dout_out(dm_dout_wb),
        .dm_we_out(dm_we_wb),
        .load_type_in(load_type_mem),
        .store_type_in(store_type_mem),
        .load_type_out(load_type_wb),
        .store_type_out(store_type_wb)
    );

    Load load(
        .dm_dout(dm_dout_wb),
        .load_type(load_type_wb),
        .load_data(load_data_wb)
    );

    Mux2 reg_write_sel(
        .src0(alu_ans_wb),
        .src1(pc_add4_wb),
        .src2(load_data_wb),
        .src3(imm_wb),
        .res(rf_wd_wb),
        .sel(rf_wd_sel_wb)
    );

    Hazard hazard(
        .rf_ra0_ex(rf_ra0_ex),
        .rf_ra1_ex(rf_ra1_ex),
        .rf_re0_ex(rf_re0_ex),
        .rf_re1_ex(rf_re1_ex),
        .rf_wa_mem(rf_wa_mem),
        .rf_we_mem(rf_we_mem),
        .rf_wd_sel_mem(rf_wd_sel_mem),
        .alu_ans_mem(alu_ans_mem),
        .pc_add4_mem(pc_add4_mem),
        .imm_mem(imm_mem),
        .rf_wa_wb(rf_wa_wb),
        .rf_we_wb(rf_we_wb),
        .rf_wd_wb(rf_wd_wb),
        .pc_sel_ex(pc_sel_ex),
        .rf_rd0_fe(rf_rd0_fe),
        .rf_rd1_fe(rf_rd1_fe),
        .rf_rd0_fd(rf_rd0_fd),
        .rf_rd1_fd(rf_rd1_fd),
        .stall_if(stall_if),
        .stall_id(stall_id),
        .stall_ex(stall_ex),
        .flush_if(flush_if),
        .flush_id(flush_id),
        .flush_ex(flush_ex),
        .flush_mem(flush_mem),
        .rf_re0_id(rf_re0_id),
        .rf_re1_id(rf_re1_id),
        .rf_ra0_id(rf_ra0_id),
        .rf_ra1_id(rf_ra1_id),
        .rf_we_ex(rf_we_ex),
        .rf_wa_ex(rf_wa_ex),
        .rf_wd_sel_ex(rf_wd_sel_ex),
        .pre_failure(pre_failure),
        .jalr_stack_rst(jalr_stack_rst),
        .jal_id(jal_id),
        .jal_ex(jal_ex),
        .jalr_id(jalr_id),
        .jalr_ex(jalr_ex),
        .top_fix(top_fix)
    );

    // Mux2 npc_sel(
    //     .src0(pc_add4_if),
    //     .src1(pc_jalr_ex),
    //     .src2(alu_ans_ex),
    //     .src3(alu_ans_ex),
    //     .res(pc_next),
    //     .sel(pc_sel_ex)
    // );

    NPC_SEL npc_sel(
        .pc_add4_if(pc_add4_if),
        .pc_jalr_ex(pc_jalr_ex),
        .alu_ans_ex(alu_ans_ex),
        .jump_addr(jump_addr),
        .jalr_addr(jalr_addr),
        .pc_sel_ex(pc_sel_ex),
        .pc_cur_id(pc_cur_id),
        .br_pre(br_pre),
        .hit(hit),
        .inst_if(inst_if),
        .pc_next(pc_next),
        .pre_failure(pre_failure),
        .pc_add4_ex(pc_add4_ex),
        .br_type_ex(br_type_ex)
    );

    Check_Data_SEL check_data_sel_if (
        .pc_cur(pc_cur_if),
        .instruction(inst_if),
        .rf_ra0(inst_if[19:15]),
        .rf_ra1(inst_if[24:20]),
        .rf_re0(1'h0),
        .rf_re1(1'h0),
        .rf_rd0_raw(32'h0),
        .rf_rd1_raw(32'h0),
        .rf_rd0(32'h0),
        .rf_rd1(32'h0),
        .rf_wa(inst_if[11:7]),
        .rf_wd_sel(2'h0),
        .rf_wd(32'h0),
        .rf_we(1'h0),
        .immediate(32'h0),
        .alu_sr1(32'h0),
        .alu_sr2(32'h0),
        .alu_func(4'h0),
        .alu_ans(32'h0),
        .pc_add4(pc_add4_if),
        .pc_br(32'h0),
        .pc_jal(32'h0),
        .pc_jalr(32'h0),
        .pc_sel(2'h0),
        .pc_next(32'h0),
        .dm_addr(32'h0),
        .dm_din(32'h0),
        .dm_dout(32'h0),
        .dm_we(1'h0),   
        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_if)
    ); 

    Check_Data_SEL check_data_sel_id (
        .pc_cur(pc_cur_id),
        .instruction(inst_id),
        .rf_ra0(rf_ra0_id),
        .rf_ra1(rf_ra1_id),
        .rf_re0(rf_re0_id),
        .rf_re1(rf_re1_id),
        .rf_rd0_raw(rf_rd0_raw_id),
        .rf_rd1_raw(rf_rd1_raw_id),
        .rf_rd0(32'h0),
        .rf_rd1(32'h0),
        .rf_wa(rf_wa_id),
        .rf_wd_sel(rf_wd_sel_id),
        .rf_wd(32'h0),
        .rf_we(rf_we_id),
        .immediate(imm_id),
        .alu_sr1(32'h0),
        .alu_sr2(32'h0),
        .alu_func(alu_func_id),
        .alu_ans(32'h0),
        .pc_add4(pc_add4_id),
        .pc_br(32'h0),
        .pc_jal(32'h0),
        .pc_jalr(32'h0),
        .pc_sel(2'h0),
        .pc_next(32'h0),
        .dm_addr(32'h0),
        .dm_din(32'h0),
        .dm_dout(32'h0),
        .dm_we(dm_we_id),   
        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_id)
    ); 

    Check_Data_SEL check_data_sel_ex (
        .pc_cur(pc_cur_ex),
        .instruction(inst_ex),
        .rf_ra0(rf_ra0_ex),
        .rf_ra1(rf_ra1_ex),
        .rf_re0(rf_re0_ex),
        .rf_re1(rf_re1_ex),
        .rf_rd0_raw(rf_rd0_raw_ex),
        .rf_rd1_raw(rf_rd1_raw_ex),
        .rf_rd0(rf_rd0_ex),
        .rf_rd1(rf_rd1_ex),
        .rf_wa(rf_wa_ex),
        .rf_wd_sel(rf_wd_sel_ex),
        .rf_wd(32'h0),
        .rf_we(rf_we_ex),
        .immediate(imm_ex),
        .alu_sr1(alu_src1_ex),
        .alu_sr2(alu_src2_ex),
        .alu_func(alu_func_ex),
        .alu_ans(alu_ans_ex),
        .pc_add4(pc_add4_ex),
        .pc_br(alu_ans_ex),
        .pc_jal(alu_ans_ex),
        .pc_jalr(pc_jalr_ex),
        .pc_sel(pc_sel_ex),
        .pc_next(pc_next),
        .dm_addr(alu_ans_ex),
        .dm_din(rf_rd1_ex),
        .dm_dout(32'h0),
        .dm_we(dm_we_ex),   
        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_ex)
    ); 

    Check_Data_SEL check_data_sel_mem (
        .pc_cur(pc_cur_mem),
        .instruction(inst_mem),
        .rf_ra0(rf_ra0_mem),
        .rf_ra1(rf_ra1_mem),
        .rf_re0(rf_re0_mem),
        .rf_re1(rf_re1_mem),
        .rf_rd0_raw(rf_rd0_raw_mem),
        .rf_rd1_raw(rf_rd1_raw_mem),
        .rf_rd0(rf_rd0_mem),
        .rf_rd1(rf_rd1_mem),
        .rf_wa(rf_wa_mem),
        .rf_wd_sel(rf_wd_sel_mem),
        .rf_wd(32'h0),
        .rf_we(rf_we_mem),
        .immediate(imm_mem),
        .alu_sr1(alu_src1_mem),
        .alu_sr2(alu_src2_mem),
        .alu_func(alu_func_mem),
        .alu_ans(alu_ans_mem),
        .pc_add4(pc_add4_mem),
        .pc_br(pc_br_mem),
        .pc_jal(pc_jal_mem),
        .pc_jalr(pc_jalr_mem),
        .pc_sel(pc_sel_mem),
        .pc_next(pc_next_mem),
        .dm_addr(dm_addr_mem),
        .dm_din(dm_din_mem),
        .dm_dout(dm_dout),
        .dm_we(dm_we_mem),   
        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_mem)
    ); 

    Check_Data_SEL check_data_sel_wb (
        .pc_cur(pc_cur_wb),
        .instruction(inst_wb),
        .rf_ra0(rf_ra0_wb),
        .rf_ra1(rf_ra1_wb),
        .rf_re0(rf_re0_wb),
        .rf_re1(rf_re1_wb),
        .rf_rd0_raw(rf_rd0_raw_wb),
        .rf_rd1_raw(rf_rd1_raw_wb),
        .rf_rd0(rf_rd0_wb),
        .rf_rd1(rf_rd1_wb),
        .rf_wa(rf_wa_wb),
        .rf_wd_sel(rf_wd_sel_wb),
        .rf_wd(rf_wd_wb),
        .rf_we(rf_we_wb),
        .immediate(imm_wb),
        .alu_sr1(alu_src1_wb),
        .alu_sr2(alu_src2_wb),
        .alu_func(alu_func_wb),
        .alu_ans(alu_ans_wb),
        .pc_add4(pc_add4_wb),
        .pc_br(pc_br_wb),
        .pc_jal(pc_jal_wb),
        .pc_jalr(pc_jalr_wb),
        .pc_sel(pc_sel_wb),
        .pc_next(pc_next_wb),
        .dm_addr(dm_addr_wb),
        .dm_din(dm_din_wb),
        .dm_dout(dm_dout_wb),
        .dm_we(dm_we_wb),   
        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_wb)
    ); 

    Check_Data_SEL_HZD check_data_sel_hzd (
        .rf_ra0_ex(rf_ra0_ex),
        .rf_ra1_ex(rf_ra1_ex),
        .rf_re0_ex(rf_re0_ex),
        .rf_re1_ex(rf_re1_ex),
        .pc_sel_ex(pc_sel_ex),
        .rf_wa_mem(rf_wa_mem),
        .rf_we_mem(rf_we_mem),
        .rf_wd_sel_mem(rf_wd_sel_mem),
        .alu_ans_mem(alu_ans_mem),
        .pc_add4_mem(pc_add4_mem),
        .imm_mem(imm_mem),
        .rf_wa_wb(rf_wa_wb),
        .rf_we_wb(rf_we_wb),
        .rf_wd_wb(rf_wd_wb),
        .rf_rd0_fe(rf_rd0_fe),
        .rf_rd1_fe(rf_rd1_fe),
        .rf_rd0_fd(rf_rd0_fd),
        .rf_rd1_fd(rf_rd1_fd),
        .stall_if(stall_if),
        .stall_id(stall_id),
        .stall_ex(stall_ex),
        .flush_if(flush_if),
        .flush_id(flush_id),
        .flush_ex(flush_ex),
        .flush_mem(flush_mem),
        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_hzd)
    );

    Check_Data_SEG_SEL check_data_seg_sel (
        .check_data_if(check_data_if),
        .check_data_id(check_data_id),
        .check_data_ex(check_data_ex),
        .check_data_mem(check_data_mem),
        .check_data_wb(check_data_wb),
        .check_data_hzd(check_data_hzd),
        .check_addr(cpu_check_addr[7:5]),
        .check_data(check_data)
    ); 

    Mux1 cpu_check_data_sel(
        .src0(check_data),
        .src1(rf_rd_dbg_id),
        .res(cpu_check_data),
        .sel(cpu_check_addr[12])
    );

    Global_Br_History global_br_history(
        .clk(clk),
        .inst_ex(inst_ex),
        .br_ex(br_ex),
        .br_pre(br_pre_global)
    );

    Partical_Br_History partical_br_history(
        .clk(clk),
        .pc_if(pc_cur_if),
        .pc_ex(pc_cur_ex),
        .inst_ex(inst_ex),
        .br_ex(br_ex),
        .br_pre(br_pre_partical)
    );

    GP_Competition gp_competition(
        .clk(clk),
        .pc_if(pc_cur_if),
        .pc_ex(pc_cur_ex),
        .inst_ex(inst_ex),
        .inst_if(inst_if),
        .br_pre_global(br_pre_global),
        .br_pre_partical(br_pre_partical),
        .br(br_ex),
        .gp_sel(gp_sel),
        .br_pre(br_pre)
    );

    BTB btb(
        .clk(clk),
        .pc_if(pc_cur_if),
        .pc_ex(pc_cur_ex),
        .pc_sel(pc_sel_ex),
        .alu_ans(alu_ans_ex),
        .hit(hit),
        .jump_addr(jump_addr)
    );

    Jalr_Stack jalr_stack(
        .clk(clk),
        .rst(jalr_stack_rst),
        .pc_if(pc_cur_if),
        .inst_if(inst_if),
        .jalr_addr(jalr_addr),
        .top_fix(top_fix)
    );

endmodule