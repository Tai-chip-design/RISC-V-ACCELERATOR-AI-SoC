`timescale 1ns/1ps
module tb_accel_controller;
    reg clk, rst, start;
    wire [4:0] t;
    wire clear, enable, busy, done;
    accel_controller dut(
        .clk(clk),
        .rst(rst),
        .start(start),
        .t(t),
        .clear(clear),
        .enable(enable),
        .busy(busy),
        .done(done)
    );
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end
    initial begin
        rst = 1;
        #12;
        rst = 0;
        start = 0; #50;
        start = 1; #500;
        start = 0; #50;
        $stop;
    end
endmodule