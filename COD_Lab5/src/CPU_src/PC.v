module PC (
    input clk,
    input stall,
    input [31:0] pc_next,
    output reg [31:0] pc_cur
);
    initial begin
        pc_cur=32'h2ffc;
    end
    always @(posedge clk) begin
        if(stall)
            pc_cur<=pc_cur;
        else
            pc_cur<=pc_next;
    end
endmodule