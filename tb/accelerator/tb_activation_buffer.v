module tb_activation_buffer;
    reg clk, load;
    reg [2:0] load_col, load_row;
    reg [4:0] t;
    reg signed [7:0] load_data;
    wire signed [7:0] activation_out [0:7];
    weight_buffer dut(
        .clk(clk),
        .load(load),
        .load_col(load_col),
        .load_row(load_row),
        .t(t),
        .load_data(load_data),
        .weight_out(activation_out)
    );
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end
    initial begin
        load = 0;
        load_col = 0;
        load_row = 0;
        t = 0;
        load_data = 0;
        #12;
        load = 1;
        // test 1
        load_data = 10;
        #10;
        // test 2
        load_col = 0;
        load_row = 1;
        load_data = 15;
        #10;
        load_col = 1;
        load_row = 0;
        t = 1;
        load_data = 20;
        #10;
        $stop;
    end
endmodule