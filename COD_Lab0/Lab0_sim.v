`timescale  1ns / 1ps

module tb_Clock(

);

// Clock Parameters
parameter PERIOD  = 10;


// Clock Inputs
reg   clk                                  = 0 ;
// Clock Reset
reg   rst                                 = 1 ;

// Clock Outputs
wire  [2:0] hour                                 ;
wire  [3:0] min                                  ;
wire  [4:0] sec                                  ;

initial begin
    #10 rst = 0;
end

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

Clock  u_Clock (
    .clk                     ( clk    ),
    .rst                     ( rst   ),
    .hour                    ( hour   ),
    .min                     ( min    ),
    .sec                     ( sec    )
);

// set simulation time
initial
begin
    #(PERIOD * 2000);
    $finish;
end

endmodule