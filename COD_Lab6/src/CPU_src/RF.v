module RF //三端口32x32寄存器堆
( 
    input clk,          //时钟（上升沿有效）
    input [4:0] ra0,    //读端口0地址
    output [31:0] rd0,  //读端口0数据
    input [4:0] ra1,    //读端口1地址
    output [31:0] rd1,  //读端口1数据
    input [4:0] wa,     //写端口地址
    input we,           //写使能，高电平有效
    input [31:0] wd,    //写端口数据
    input [4:0] ra_dbg, //PDU从外部读取寄存器
    output [31:0] rd_dbg
);
    reg [31:0] regfile [0:31];
    integer i;
    initial begin
        i=0;
        while(i<32)begin
            regfile[i]=32'b0;
            i=i+1;
        end
        regfile[2]=32'h2ffc;
        regfile[3]=32'h1800;
    end

    assign rd0 = 
        ra0==0 ? 0:             //x0=0
        we==1 && ra0==wa ? wd:  //写优先
        regfile[ra0];
    assign rd1 = 
        ra1==0 ? 0:
        we==1 && wa==ra1 ? wd:
        regfile[ra1];
    assign rd_dbg = 
        ra_dbg==0 ? 0:
        we==1 && ra_dbg==wa ? wd:
        regfile[ra_dbg];

    always @ (posedge clk) begin
        if(we)begin
            if(wa)
                regfile[wa] <= wd;
            else
                regfile[wa] <= 0;
        end
    end

endmodule