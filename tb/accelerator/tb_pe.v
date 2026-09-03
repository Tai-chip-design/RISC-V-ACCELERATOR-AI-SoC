module tb_pe;
    reg clk, rst, clear, enable;
    reg signed [7:0] weight, activation;
    wire signed [7:0] weight_out, activation_out;
    wire signed [31:0] acc_out;
    pe dut(
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .weight(weight),
        .activation(activation),
        .weight_out(weight_out),
        .activation_out(activation_out),
        .acc_out(acc_out)
    );
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end
    initial begin
        rst = 1;
        clear = 0;
        enable = 0;
        weight = 0;
        activation = 0;
        #12;
        rst = 0;
        enable = 1;
        // test 1;
        weight = 5;
        activation = 10;
        #10;
        //test 2
        weight = 8;
        activation = 10;
        #10;
        //test 3
         weight = 4;
         activation = 5;
         #10;
         // clear
         clear = 1;
         #10;
         clear = 0;
         weight = 20;
         activation = 10;
         #10;
         enable = 0;
         #50;
         $stop;
    end
endmodule