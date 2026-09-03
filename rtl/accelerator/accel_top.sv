module accel_top (
    input clk, rst, start,
    input signed [7:0] weight_data, activation_data,
    input [2:0] load_row, load_col,
    input weight_load, activation_load,
    input signed [31:0] scale,
    input [4:0] shift,
    output busy, done,
    output signed [7:0] result [0:7][0:7]
);
    wire [4:0] t;
    wire clear, enable;
    accel_controller ctrl(.clk(clk), .rst(rst), .start(start), .t(t), .clear(clear), .enable(enable), .busy(busy), .done(done));
    wire signed [7:0] weight_out [0:7];
    wire signed [7:0] activation_out [0:7];
    weight_buffer wb(.clk(clk), .load(weight_load), .load_col(load_col), .load_row(load_row), .t(t), .load_data(weight_data), .weight_out(weight_out));
    activation_buffer ab(.clk(clk), .load(activation_load), .load_col(load_col), .load_row(load_row), .t(t), .load_data(activation_data), .activation_out(activation_out));
    wire signed [31:0] acc [0:7][0:7];
    pe_array pa(.clk, .rst(rst), .enable(enable), .clear(clear), .weight(weight_out), .activation(activation_out), .acc_out(acc));
    genvar i, j;
    generate
        for(i=0; i<8;i=i+1) begin
            for(j=0;j<8;j=j+1) begin
                requantize re(.acc_in(acc[i][j]), .scale(scale), .shift(shift), .out_int8(result[i][j]));
            end
        end
    endgenerate
endmodule