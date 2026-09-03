module tb_requantize;
    reg [31:0] acc_in;
    reg signed [31:0] scale;
    reg [4:0] shift;
    wire signed [7:0] out_int8;
    requantize dut(
        .acc_in(acc_in),
        .scale(scale),
        .shift(shift),
        .out_int8(out_int8)
    );
    initial begin
        acc_in = 0;
        scale = 0;
        shift = 0;
        #10;
        acc_in = 800;
        scale = 1;
        shift = 2;
        #10;
        acc_in = -800;
        scale = 1;
        shift = 2;
        #10;
        acc_in = 300;
        scale = 10;
        shift = 5;
        #10;
        $stop;
    end
endmodule