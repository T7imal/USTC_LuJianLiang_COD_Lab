module NPC_SEL (
    input clk,
    input [31:0] pc_add4_if,
    input [31:0] pc_jalr_ex,
    input [31:0] alu_ans_ex,
    input [31:0] jump_addr,
    input [31:0] jalr_addr,
    input [1:0] pc_sel_ex,
    input [31:0] pc_cur_id,
    input [31:0] pc_add4_ex,
    input [2:0] br_type_ex,
    input br_pre,
    input hit,
    input [31:0] inst_if,
    output reg [31:0] pc_next,
    output reg pre_failure, //当预测失败时为1
    output reg [31:0] br_num,
    output reg [31:0] jal_num,
    output reg [31:0] jalr_num,
    output reg [31:0] br_fail_num,  //预测失败的次数
    output reg [31:0] jal_fail_num,
    output reg [31:0] jalr_fail_num
);
    initial begin
        br_num=0; jal_num=0; jalr_num=0;
        br_fail_num=0; jal_fail_num=0; jalr_fail_num=0;
    end

    always @(*) begin
        pc_next=pc_add4_if;
        pre_failure=0;
        case (pc_sel_ex)
            2'h0: begin //ex阶段是不应该跳转，根据if阶段预测pc_next
                if(pc_cur_id!=pc_add4_ex && br_type_ex!=0)begin //ex阶段是br指令，且本不应该跳转
                    pre_failure=1;  //预测失败，插入气泡
                    pc_next=pc_add4_ex;
                end
                else begin
                    case (inst_if[6:0])
                        7'b1101111: begin   //jal
                            if(hit)
                                pc_next=jump_addr;
                        end
                        7'b1100111: begin   //jalr
                            pc_next=jalr_addr;
                        end
                        7'b1100011: begin   //br
                            if(br_pre)
                                if(hit)
                                    pc_next=jump_addr;
                        end
                    endcase
                end
                
            end
            2'h1: begin //ex阶段为jalr指令，jalr指令"在99%的情况下"一定被正确预测，但在助教的测试程序中不行
                if(pc_cur_id!=pc_jalr_ex)begin
                    pre_failure=1;  //预测失败，插入气泡
                    pc_next=pc_jalr_ex;
                end
                else begin
                    case (inst_if[6:0])
                        7'b1101111: begin   //jal
                            if(hit)
                                pc_next=jump_addr;
                        end
                        7'b1100111: begin   //jalr
                            pc_next=jalr_addr;
                        end
                        7'b1100011: begin   //br
                            if(br_pre)
                                if(hit)
                                    pc_next=jump_addr;
                        end
                    endcase
                end
            end
            2'h2: begin //ex阶段为br指令，需要检测br指令ex阶段预测是否正确，若不正确则pc_next=alu_ans_ex
                if(pc_cur_id!=alu_ans_ex)begin
                    pre_failure=1;  //预测失败，插入气泡
                    pc_next=alu_ans_ex;
                end
                else begin  //ex阶段预测成功，根据if阶段预测pc_next
                    case (inst_if[6:0])
                        7'b1101111: begin   //jal
                            if(hit)
                                pc_next=jump_addr;
                        end
                        7'b1100111: begin   //jalr
                            pc_next=jalr_addr;
                        end
                        7'b1100011: begin   //br
                            if(br_pre)
                                if(hit)
                                    pc_next=jump_addr;
                        end
                    endcase
                end
            end
            2'h3: begin //ex阶段为jal指令，需要检测jal指令ex阶段预测是否正确，若不正确则pc_next=pc_jalr_ex
                if(pc_cur_id!=pc_jalr_ex)begin
                    pre_failure=1;  //预测失败，插入气泡
                    pc_next=pc_jalr_ex;
                end
                else begin  //ex阶段预测成功，根据if阶段预测pc_next
                    case (inst_if[6:0])
                        7'b1101111: begin   //jal
                            if(hit)
                                pc_next=jump_addr;
                        end
                        7'b1100111: begin   //jalr
                            pc_next=jalr_addr;
                        end
                        7'b1100011: begin   //br
                            if(br_pre)
                                if(hit)
                                    pc_next=jump_addr;
                        end
                    endcase
                end
            end
        endcase
    end

    always @(posedge clk) begin
        case (pc_sel_ex)
            2'h0: begin //ex阶段是不应该跳转，根据if阶段预测pc_next
                if(pc_cur_id!=pc_add4_ex && br_type_ex!=0)begin //ex阶段是br指令，且本不应该跳转
                    br_num<=br_num+1;
                    br_fail_num<=br_fail_num+1;
                end
                else if(br_type_ex!=0)
                    br_num<=br_num+1;
            end
            2'h1: begin //ex阶段为jalr指令，jalr指令"在99%的情况下"一定被正确预测，但在助教的全指令测试程序中不行
                if(pc_cur_id!=pc_jalr_ex)begin
                    jalr_num<=jalr_num+1;
                    jalr_fail_num<=jalr_fail_num+1;
                end
                else 
                    jalr_num<=jalr_num+1;
            end
            2'h2: begin //ex阶段为br指令，需要检测br指令ex阶段预测是否正确，若不正确则pc_next=alu_ans_ex
                if(pc_cur_id!=alu_ans_ex)begin
                    br_num<=br_num+1;
                    br_fail_num<=br_fail_num+1;
                end
                else 
                    br_num<=br_num+1;
            end
            2'h3: begin //ex阶段为jal指令，需要检测jal指令ex阶段预测是否正确，若不正确则pc_next=pc_jalr_ex
                if(pc_cur_id!=pc_jalr_ex)begin
                    jal_num<=jal_num+1;
                    jal_fail_num<=jal_fail_num+1;
                end
                else 
                    jal_num<=jal_num+1;
            end
        endcase
    end
endmodule