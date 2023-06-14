module GP_Competition (
    input clk,
    input [31:0] pc_if,
    input [31:0] pc_ex,
    input [31:0] inst_ex,
    input [31:0] inst_if,
    input br_pre_global_if,
    input br_pre_partical_if,
    input br_pre_global_ex,
    input br_pre_partical_ex,
    input br,
    output reg gp_sel, //使用全局(1)/分支(0)历史预测
    output br_pre
);
    wire br_inst, gp_sel_ex;
    wire [5:0] pc_if_hash, pc_ex_hash;
    reg [1:0] gpht[0:63];
    integer i=0;

    assign br_inst= (inst_ex[6:0]==7'b1100011) ? 1 : 0;
    assign pc_if_hash=pc_if[15:10]^pc_if[7:2];
    assign pc_ex_hash=pc_ex[15:10]^pc_ex[7:2];
    assign gp_sel_ex= (br==br_pre_global_ex) ? 1 : 0;   //全局历史预测优先，全局正确时认为是全局
    assign br_pre= (inst_if[6:0]!=7'b1100011) ? 0 :
        (gp_sel) ? br_pre_global_if : br_pre_partical_if;

    always @(*) begin
        if(br_inst && pc_if==pc_ex)begin    //写优先
            case (gpht[pc_ex_hash])
                2'b00: gp_sel=0;
                2'b01: gp_sel= (gp_sel_ex) ? 1 : 0;
                2'b10: gp_sel= (gp_sel_ex) ? 1 : 0;
                2'b11: gp_sel=1;
            endcase
        end
        case (gpht[pc_if_hash])
            2'b00: gp_sel=0;
            2'b01: gp_sel=0;
            2'b10: gp_sel=1;
            2'b11: gp_sel=1;
        endcase
    end

    initial begin
        for (i=0; i<256; i=i+1) begin
            gpht[i]=2'h0;    //所有GBHR初值为零
        end
    end

    always @(posedge clk) begin
        if(br_inst)
            case (gpht[pc_ex_hash])
                2'b00: gpht[pc_ex_hash]<= (gp_sel_ex) ? 2'b01 : 2'b00; //强局部
                2'b01: gpht[pc_ex_hash]<= (gp_sel_ex) ? 2'b10 : 2'b00; //弱局部
                2'b10: gpht[pc_ex_hash]<= (gp_sel_ex) ? 2'b11 : 2'b01; //弱全局
                2'b11: gpht[pc_ex_hash]<= (gp_sel_ex) ? 2'b11 : 2'b10; //强全局
            endcase
    end
    
endmodule