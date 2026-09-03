`timescale 1ns/1ps
module tb_alu;
    reg [31:0] a, b;
    reg [3:0] alu_control;
    wire [31:0] result;
    wire zero;
    alu dut(
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );
    initial begin
        a = 20;
        b = 30;
        alu_control = 4'b0000; #10;
        alu_control = 4'b0001; #10;
        alu_control = 4'b0010; #10;
        alu_control = 4'b0011; #10;
        alu_control = 4'b0100; #10;
        alu_control = 4'b1111; #10;
        $stop;
    end
endmodule