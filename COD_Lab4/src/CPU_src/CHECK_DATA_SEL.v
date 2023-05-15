module CHECK_DATA_SEL (
    input [31:0] pc_in,
    input [31:0] pc_out,
    input [31:0] instruction,
    input [4:0] rf_ra0,
    input [4:0] rf_ra1,
    input [31:0] rf_rd0,
    input [31:0] rf_rd1,
    input [4:0] rf_wa,
    input [31:0] rf_wd,
    input rf_we,
    input [31:0] imm,
    input [31:0] alu_sr1,
    input [31:0] alu_sr2,
    input [3:0] alu_func,
    input [31:0] alu_ans,
    input [31:0] pc_jalr,
    input [31:0] dm_addr,
    input [31:0] dm_din,
    input [31:0] dm_dout,
    input [31:0] dm_we,
    input [31:0] check_addr,
    output reg [31:0] check_data
);
    always @(*) begin
        
        case(check_addr[7:0])
            8'h01: check_data = pc_in;  // 即将写入的 PC
            8'h02: check_data = pc_out; // 当前 PC
            8'h03: check_data = instruction; // 当前指令
            8'h04: check_data = rf_ra0; // 寄存器堆读地址 0
            8'h05: check_data = rf_ra1; // 寄存器堆读地址 1
            8'h06: check_data = rf_rd0; // 寄存器数据 0
            8'h07: check_data = rf_rd1; // 寄存器数据 1
            8'h08: check_data = rf_wa; // 寄存器堆写地址
            8'h09: check_data = rf_wd; // 寄存器堆写数据	<---- NEW
            8'h0a: check_data = rf_we; // 寄存器堆写使能
            8'h0b: check_data = imm; // 立即数模块输出
            8'h0c: check_data = alu_sr1; // ALU 输入 1 
            8'h0d: check_data = alu_sr2; // ALU 输入 2
            8'h0e: check_data = alu_func; // ALU 模式码
            8'h0f: check_data = alu_ans; // ALU 运算结果
            8'h10: check_data = pc_jalr; // Jalr 指令目标地址
            8'h11: check_data = dm_addr; // 存储器读写地址
            8'h12: check_data = dm_din; // 存储器写入数据
            8'h13: check_data = dm_dout; // 存储器读出数据
            8'h14: check_data = dm_we; // 存储器写使能
            default: check_data = 0;
        endcase
    end
endmodule