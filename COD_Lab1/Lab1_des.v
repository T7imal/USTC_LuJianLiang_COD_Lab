module fls
(
input clk, rst, //时钟，复位（高电平有效）
input en, //输入输出使能，按一次使能一个数据输入/输出
input [6:0] d, //输入数列初始项
output [6:0] f //输出数列
);
    reg [1:0] c_state=0;
    reg [1:0] n_state=0;
    reg en_1=0;
    reg en_2=0;
    reg [3:0] func=4'b0000;
    reg [6:0] f1;
    reg [6:0] f2;
    wire [6:0] f3;

    always @(posedge clk) begin
        if(rst)begin
            c_state<=2'b00;
        end
        else c_state<=n_state;
    end
    
    always @(posedge clk) begin
        en_1<=en_2;
        en_2<=en;
    end

    always @(*) begin
        n_state=c_state;
        if(!rst)begin
            case(c_state)
                2'b00:begin
                    if(~en_1&en_2)begin
                        n_state=2'b01;
                    end
                end
                2'b01:begin
                    if(~en_1&en_2)begin
                        n_state=2'b10;
                    end
                end
                2'b10:begin
                    if(~en_1&en_2)begin
                        n_state=2'b10;
                    end
                end
            endcase 
        end
    end
    
    always @(posedge clk) begin
        f1<=f1;
        f2<=f2;
        if(rst)begin
            f1<=0;
            f2<=0;
        end
        else begin
            case(c_state)
                2'b00:begin
                    if(~en_1&en_2)begin
                        f2<=d;
                    end
                end
                2'b01:begin
                    if(~en_1&en_2)begin
                        f1<=f2;
                        f2<=d;
                    end
                end
                2'b10:begin
                    if(~en_1&en_2)begin
                        f1<=f2;
                        f2<=f3;
                    end
                end
            endcase 
        end
    end
    
    always@(*) func=d[3:0];

    assign f=f2;

    alu #(.WIDTH(7)) alu_2  (
        .a(f1),
        .b(f2),
        .func(func),
        .y(f3),
        .of()
    );

endmodule

module alu_test
(
input clk,
input en,
input [1:0]sel,
input [5:0] x,
output [5:0] y,
output of
);
    reg ena, enb,enf;
    reg [5:0] areg;
    reg [5:0] breg;
    reg [3:0] freg;
    always @(*) begin
        ena=0;
        enb=0;
        enf=0;
        if(en)begin
            case(sel)
                2'b00:ena=1;
                2'b01:enb=1;
                2'b10:enf=1;
                default:begin
                    ena=0;
                    enb=0;
                    enf=0;
                end
            endcase
        end
        else begin
            ena=0;
            enb=0;
            enf=0;
        end
    end

    always @(posedge clk) begin
        if(ena)
            areg<=x;
        else if(enb)
            breg<=x;
        else if(enf)
            freg<=x[3:0];
        else begin
            areg<=areg;
            breg<=breg;
            freg<=freg;
        end
    end

    alu alu_1 (
        .a(areg),
        .b(breg),
        .func(freg),
        .y(y),
        .of(of)
    );

endmodule

module alu #(parameter WIDTH = 6) //数据宽度
(
input [WIDTH-1:0] a, b, //两操作数（对于减运算，a是被减数）
input [3:0] func, //操作功能（加、减、与、或、异或等）
output [WIDTH-1:0] y, //运算结果（和、差 …）
output of //溢出标志of，加减法结果溢出时置1
);
    reg [WIDTH-1:0] yreg;
    reg ofreg;
    always @(*) begin
        yreg=0;
        ofreg=0;
        case (func)
            4'b0000:begin
                yreg=a+b;
                if((a[WIDTH-1]&b[WIDTH-1]&~yreg[WIDTH-1])|(~a[WIDTH-1]&~b[WIDTH-1]&yreg[WIDTH-1]))
                    ofreg=1;
            end
            4'b0001:begin
                yreg=a+~b+1;
                if((a[WIDTH-1]&~b[WIDTH-1]&~yreg[WIDTH-1])|(~a[WIDTH-1]&b[WIDTH-1]&yreg[WIDTH-1]))
                    ofreg=1;
            end
            4'b0010:begin
                if(a==b)
                    yreg=1;
            end
            4'b0011:begin
                if(a<b)
                    yreg=1;
            end
            4'b0100:begin
                if($signed(a)<$signed(b))
                    yreg=1;
            end
            4'b0101:begin
                yreg=a&b;
            end
            4'b0110:begin
                yreg=a|b;
            end
            4'b0111:begin
                yreg=a^b;
            end
            4'b1000:begin
                yreg=a>>b;
            end
            4'b1001:begin
                yreg=a<<b;
            end
            default:begin
                yreg=0;
                ofreg=0;
            end
        endcase
    end
    assign y=yreg;
    assign of=ofreg;
endmodule