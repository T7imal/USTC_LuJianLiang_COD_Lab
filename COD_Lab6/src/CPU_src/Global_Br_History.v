module GHR (
    input clk,
    input br_inst,  //ex阶段是否是br指令
    input br,
    output [7:0] br_history
);
    reg [7:0] ghr;

    assign br_history= (br_inst) ? {ghr[6:0],br} : ghr; //写优�?
    
    initial begin
        ghr=8'h0;
    end

    always @(posedge clk) begin
        if(br_inst)
            ghr<={ghr[6:0],br}; //移位寄存�?
    end
endmodule

module PHT_Global (
    input clk,
    input br_inst,  //是否是br指令
    input br,
    input [7:0] br_history,
    output reg br_pre
);
    reg [1:0] pht [0:255];
    integer i=0;

    always @(*) begin
        if(br_inst)begin    //写优�?
            case (pht[br_history])
                2'b00: br_pre=0;
                2'b01: br_pre= (br) ? 1 : 0;
                2'b10: br_pre= (br) ? 1 : 0;
                2'b11: br_pre=1;
            endcase
        end
        else begin
            case (pht[br_history])
                2'b00: br_pre=0;
                2'b01: br_pre=0;
                2'b10: br_pre=1;
                2'b11: br_pre=1;
            endcase
        end
    end

    initial begin
        for (i=0; i<256; i=i+1) begin
                pht[i]=2'b01;    //弱不跳转
        end
    end    

    always @(posedge clk) begin
        if (br_inst) begin
            case (pht[br_history])
                2'b00: pht[br_history]<= (br) ? 2'b01 : 2'b00; //强不跳转
                2'b01: pht[br_history]<= (br) ? 2'b10 : 2'b00; //弱不跳转
                2'b10: pht[br_history]<= (br) ? 2'b11 : 2'b01; //弱跳�?
                2'b11: pht[br_history]<= (br) ? 2'b11 : 2'b10; //强跳�?
            endcase
        end
    end
endmodule

module Global_Br_History (
    input clk,
    input [31:0] inst_ex,
    input br_ex,
    output br_pre
);
    wire br_inst;
    wire [7:0] br_history;
    assign br_inst= (inst_ex[6:0]==7'b1100011) ? 1 : 0;

    GHR ghr(
        .clk(clk),
        .br_inst(br_inst),
        .br(br_ex),
        .br_history(br_history)
    );

    PHT_Global pht_global(
        .clk(clk),
        .br_inst(br_inst),
        .br(br_ex),
        .br_history(br_history),
        .br_pre(br_pre)
    );
endmodule