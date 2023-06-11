module BHT (
    input clk,
    input [31:0] pc_if,
    input [31:0] pc_ex,
    input br_inst,  //是否是br指令
    input br,
    output [3:0] br_history_if,
    output [3:0] br_history_ex
);
    reg [3:0] bht [0:63];
    wire [5:0] pc_if_hash, pc_ex_hash;
    integer i=0;

    assign pc_if_hash=pc_if[15:10]^pc_if[7:2];
    assign pc_ex_hash=pc_ex[15:10]^pc_ex[7:2];
    assign br_history_if= (br_inst && pc_if==pc_ex) ? {bht[pc_ex_hash][2:0],br} : bht[pc_if_hash];    //写优先
    assign br_history_ex= (br_inst) ? {bht[pc_ex_hash][2:0],br} : bht[pc_ex_hash];  //写优先
    
    initial begin
        for (i=0; i<64; i=i+1) begin
            bht[i]=4'h0;    //所有BHR初值为零
        end
    end

    always @(posedge clk) begin
        if(br_inst)
            bht[pc_ex_hash]<={bht[pc_ex_hash][2:0],br};  //移位寄存器
    end
endmodule

module PHT_Partical (
    input clk,
    input [31:0] pc_if,
    input [31:0] pc_ex,
    input br_inst,  //是否是br指令
    input br,
    input [3:0] br_history_if,
    input [3:0] br_history_ex,
    output reg br_pre
);
    reg [1:0] pht [0:63][0:15];
    wire [5:0] pc_if_hash, pc_ex_hash;
    integer i=0, j=0;

    assign pc_if_hash=pc_if[15:10]^pc_if[7:2];
    assign pc_ex_hash=pc_ex[15:10]^pc_ex[7:2];

    always @(*) begin
        if(br_inst && pc_if==pc_ex)begin    //写优先
            case (pht[pc_ex_hash][br_history_ex])
                2'b00: br_pre=0;
                2'b01: br_pre= (br) ? 1 : 0;
                2'b10: br_pre= (br) ? 1 : 0;
                2'b11: br_pre=1;
            endcase
        end
        else begin
            case (pht[pc_if_hash][br_history_if])
                2'b00: br_pre=0;
                2'b01: br_pre=0;
                2'b10: br_pre=1;
                2'b11: br_pre=1;
            endcase
        end
    end

    initial begin
        for (i=0; i<64; i=i+1) begin
            for (j=0; j<16; j=j+1) begin
                pht[i][j]=2'b01;    //弱不跳转
            end
        end    
    end

    always @(posedge clk) begin
        if (br_inst) begin
            case (pht[pc_ex_hash][br_history_ex])
                2'b00: pht[pc_ex_hash][br_history_ex]<= (br) ? 2'b01 : 2'b00;
                2'b01: pht[pc_ex_hash][br_history_ex]<= (br) ? 2'b10 : 2'b00;
                2'b10: pht[pc_ex_hash][br_history_ex]<= (br) ? 2'b11 : 2'b01;
                2'b11: pht[pc_ex_hash][br_history_ex]<= (br) ? 2'b11 : 2'b10;
            endcase
        end
    end
endmodule

module Partical_Br_History (
    input clk,
    input [31:0] pc_if,
    input [31:0] pc_ex,
    input [31:0] inst_ex,
    input br_ex,
    output br_pre
);
    wire br_inst;
    wire [3:0] br_history_if;
    wire [3:0] br_history_ex;
    assign br_inst= (inst_ex[6:0]==7'b1100011) ? 1 : 0;

    BHT bht(
        .clk(clk),
        .pc_if(pc_if),
        .pc_ex(pc_ex),
        .br_inst(br_inst),
        .br(br_ex),
        .br_history_if(br_history_if),
        .br_history_ex(br_history_ex)
    );

    PHT_Partical pht_partical(
        .clk(clk),
        .pc_if(pc_if),
        .pc_ex(pc_ex),
        .br_inst(br_inst),
        .br(br_ex),
        .br_history_if(br_history_if),
        .br_history_ex(br_history_ex),
        .br_pre(br_pre)
    );
endmodule