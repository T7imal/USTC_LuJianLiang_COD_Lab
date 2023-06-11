module Hazard (
    input [4:0] rf_ra0_ex,
    input [4:0] rf_ra1_ex,
    input [4:0] rf_ra0_id,
    input [4:0] rf_ra1_id,
    input rf_re0_ex,
    input rf_re1_ex,
    input rf_re0_id,
    input rf_re1_id,
    input [4:0] rf_wa_mem,
    input [4:0] rf_wa_ex,
    input rf_we_mem,
    input rf_we_ex,
    input [1:0] rf_wd_sel_mem,
    input [1:0] rf_wd_sel_ex,
    input [31:0] alu_ans_mem,
    input [31:0] pc_add4_mem,
    input [31:0] imm_mem,
    input [4:0] rf_wa_wb,
    input rf_we_wb,
    input [31:0] rf_wd_wb,
    input [1:0] pc_sel_ex,
    input pre_failure,
    input jal_id,
    input jal_ex,
    input jalr_id,
    input jalr_ex,
    output reg rf_rd0_fe,
    output reg rf_rd1_fe,
    output reg [31:0] rf_rd0_fd,
    output reg [31:0] rf_rd1_fd,
    output reg stall_if,
    output reg stall_id,
    output reg stall_ex,
    output reg flush_if,
    output reg flush_id,
    output reg flush_ex,
    output reg flush_mem,
    output reg jalr_stack_rst,
    output reg [1:0] top_fix
);
    reg [31:0] rf_wd_mem;
    always @(*) begin
        rf_wd_mem=0;
        case (rf_wd_sel_mem)
            0: rf_wd_mem=alu_ans_mem;
            1: rf_wd_mem=pc_add4_mem;
            3: rf_wd_mem=imm_mem;       //rf_wd_sel_mem==2时，写回值源于数据存储器，需要插入气泡
        endcase
    end

    always @(*) begin
        rf_rd0_fe=0; rf_rd0_fd=0; rf_rd1_fe=0; rf_rd1_fd=0;
        stall_if=0; stall_id=0; stall_ex=0;
        flush_if=0; flush_id=0; flush_ex=0; flush_mem=0;
        jalr_stack_rst=0; top_fix=0;
        if (rf_we_ex && rf_re0_id && rf_wa_ex == rf_ra0_id && rf_wd_sel_ex == 2
            || rf_we_ex && rf_re1_id && rf_wa_ex == rf_ra1_id && rf_wd_sel_ex == 2)begin    //形如addi, lw, add产生冒险
            stall_if = 1;
            stall_id = 1;
            flush_ex = 1;
        end
        else begin
            if(rf_we_wb)begin   //上上条指令存在写回寄存器堆
                if(rf_re0_ex==1 && rf_ra0_ex==rf_wa_wb)begin    //这一条指令需要读寄存器堆，且所读寄存器与上一条指令写回的寄存器相同
                    rf_rd0_fe=1;
                    rf_rd0_fd=rf_wd_wb;
                end
                if(rf_re1_ex==1 && rf_ra1_ex==rf_wa_wb)begin    //这一条指令需要读寄存器堆，且所读寄存器与上一条指令写回的寄存器相同
                    rf_rd1_fe=1;
                    rf_rd1_fd=rf_wd_wb;
                end
            end
            if(rf_we_mem)begin  //上一条指令存在写回寄存器堆
                if(rf_re0_ex==1 && rf_ra0_ex==rf_wa_mem)begin   //这一条指令需要读寄存器堆，且所读寄存器与上一条指令写回的寄存器相同
                    if(rf_wd_sel_mem==2)begin   //上一条指令写回值源于数据存储器，需要插入气泡
                        stall_if=1;
                        stall_id=1;
                        stall_ex=1;
                        flush_mem=1;
                    end
                    rf_rd0_fe=1;
                    rf_rd0_fd=rf_wd_mem;
                end
                if(rf_re1_ex==1 && rf_ra1_ex==rf_wa_mem)begin   //这一条指令需要读寄存器堆，且所读寄存器与上一条指令写回的寄存器相同
                    if(rf_wd_sel_mem==2)begin   //上一条指令写回值源于数据存储器，需要插入气泡
                        stall_if=1;
                        stall_id=1;
                        stall_ex=1;
                        flush_mem=1;
                    end
                    rf_rd1_fe=1;
                    rf_rd1_fd=rf_wd_mem;
                end
            end
        end
        
        if(pre_failure)begin
            case (pc_sel_ex)
                2'h0: begin //ex阶段不应该跳转，但跳转了，
                    top_fix=jalr_id+jalr_ex-jal_id-jal_ex;
                    flush_id=1;
                    flush_ex=1;
                end
                2'h1: begin //jalr预测失败，说明jalr不是用于函数调用的返回，为了安全清空jalr栈
                    jalr_stack_rst=1;
                    flush_id=1;
                    flush_ex=1;
                end
                2'h2: begin //br
                    top_fix=jalr_id+jalr_ex-jal_id-jal_ex;
                    flush_id=1;
                    flush_ex=1;
                end
                2'h3: begin//jal
                    top_fix=jalr_id+jalr_ex;
                    flush_id=1;
                    flush_ex=1;
                end
            endcase
        end
    end
endmodule