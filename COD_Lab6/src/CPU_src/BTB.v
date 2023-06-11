module BTB (
    input clk,
    input [31:0] pc_if,
    input [31:0] pc_ex,
    input [1:0] pc_sel,
    input [31:0] alu_ans,
    output reg hit,
    output reg [31:0] jump_addr
);
    wire [5:0] pc_if_hash, pc_ex_hash;
    wire [3:0] tag_if, tag_ex;
    reg [3:0] tag [0:63];
    reg [31:0] jat [0:63];  //jump addr table
    integer i=0;

    assign tag_if=pc_if[5:2];
    assign tag_ex=pc_ex[5:2];
    assign pc_if_hash=pc_if[15:10]^pc_if[7:2];
    assign pc_ex_hash=pc_ex[15:10]^pc_ex[7:2];

    initial begin
        for(i=0; i<64; i=i+1)begin
            tag[i]=4'h0;
            jat[i]=32'h0;
        end
    end

    always @(*) begin
        if(pc_if==pc_ex)begin
            hit=1;
            jump_addr=alu_ans;
        end
        else begin
            if(tag_if==tag[pc_if_hash])begin
                hit=1;
                jump_addr=jat[pc_if_hash];
            end
            else begin
                hit=0;
                jump_addr=0;
            end
        end
        
    end
    always @(posedge clk) begin
        if(pc_sel==2 || pc_sel==3)begin //jal, br
            if(tag[pc_ex_hash]!=tag_ex)begin
                jat[pc_ex_hash]<=alu_ans;
                tag[pc_ex_hash]<=tag_ex;
            end
        end
    end
endmodule