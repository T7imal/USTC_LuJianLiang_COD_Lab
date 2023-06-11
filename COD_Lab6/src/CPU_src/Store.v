module Store (
    input [31:0] dm_din,
    input [31:0] dm_dout,
    input [1:0] store_type,
    output reg [31:0] store_data
);
    always @(*) begin
        case (store_type)
            2'h1: store_data={dm_din[7:0], dm_dout[23:0]};  //sb
            2'h2: store_data={dm_din[15:0], dm_dout[15:0]}; //sh
            2'h3: store_data=dm_din;                        //sw
            default: store_data=0;
        endcase
    end
endmodule