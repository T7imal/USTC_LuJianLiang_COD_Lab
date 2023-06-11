module Load (
    input [31:0] dm_dout,
    input [2:0] load_type,
    output reg [31:0] load_data
);
    always @(*) begin
        case (load_type)
            3'h1: load_data={{24{dm_dout[31]}}, dm_dout[31:24]};    //lb
            3'h2: load_data={{16{dm_dout[31]}}, dm_dout[31:16]};    //lh
            3'h3: load_data=dm_dout;                                //lw
            3'h4: load_data={24'h0, dm_dout[31:24]};                //lbu
            3'h5: load_data={16'h0, dm_dout[31:16]};                //lhu
            default: load_data=32'h0;
        endcase
    end  
endmodule