module alu_test_sim (
);
    reg clk;
    reg en;
    reg [1:0] sel;
    reg [5:0] x;
    wire [5:0] y;
    wire of;

    always begin
        clk=0;
        forever begin
            #5 clk=~clk;
        end
    end

    initial begin
        en=1; sel=2'b00; x=6'b010000;
        #20 en=1; sel=2'b01; x=6'b000001;
        #20 en=1; sel=2'b10; x=6'b000000;
        forever begin
            #20 x=x+1;
        end
    end

    alu_test alu_test(
        .clk(clk),
        .en(en),
        .sel(sel),
        .x(x),
        .y(y),
        .of(of)
    );
endmodule

module fls_test_sim (
);
    reg clk;
    reg rst;
    reg en;
    reg [6:0] d;
    wire [6:0] f;

    always begin
        clk=0;
        forever begin
            #5 clk=~clk;
        end
    end

    initial begin
        rst=1; en=0;
        #20 rst=0; d=7'h02;
        #100 en=1;
        #100 en=0;
        #100 d=7'h03;
        #100 en=1;
        #100 en=0; d=7'h0;
        #100 en=1;
        #100 en=0;
        #100 en=1;
        #100 en=0;
        #100 en=1;
        #100 en=0;
        #100 en=1;
        #100 en=0; d=7'b0000001;
        #100 en=1;
        #100 en=0;
        #100 en=1;
        #100 en=0;
        #100 en=1;
        #100 en=0;
        #100 en=1;
        #100 en=0;
        #100 en=1;
        #100 en=0;
        #100 en=1;
        #100 en=0;
        forever begin
            #100 en=0;
            #100 en=1;
        end
    end

    fls fls(
        .clk(clk),
        .rst(rst),
        .en(en),
        .d(d),
        .f(f)
    );
endmodule