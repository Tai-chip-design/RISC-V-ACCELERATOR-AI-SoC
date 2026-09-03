module tb_accel_top;
    reg clk, rst, start;
    reg signed [7:0] weight_data, activation_data;
    reg [2:0] load_row, load_col;
    reg weight_load, activation_load;
    reg signed [31:0] scale;
    reg [4:0] shift;
    wire busy, done;
    wire signed [7:0] result [0:7][0:7];
    accel_top dut(
        .clk(clk),
        .rst(rst),
        .start(start),
        .weight_data(weight_data),
        .activation_data(activation_data),
        .load_row(load_row),
        .load_col(load_col),
        .weight_load(weight_load),
        .activation_load(activation_load),
        .scale(scale),
        .shift(shift),
        .busy(busy),
        .done(done),
        .result(result)
    );
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end
    reg signed [7:0] w [0:7][0:7];
    reg signed [7:0] a [0:7][0:7];
    integer expected_acc [0:7][0:7];
    reg signed [7:0] expected_out [0:7][0:7];
    reg signed [63:0] scaled_t;
    integer i, j, k, count_fail, count_cycle;
    task load_matrix;
        begin
            weight_load = 0;
            activation_load = 0;
            for(i=0;i<8;i=i+1) begin
                for(j=0;j<8;j=j+1) begin
                    @(negedge clk);
                    load_row = i;
                    load_col = j;
                    weight_data = w[i][j];
                    activation_data = a[i][j];
                    weight_load = 1;
                    activation_load = 1;
                end
            end
            @(negedge clk);
            weight_load = 0;
            activation_load = 0;
        end
    endtask
    initial begin
        rst = 1; 
        start = 0;
        weight_data = 0;
        activation_data = 0;
        load_row = 0;
        load_col = 0;
        weight_load = 0;
        activation_load = 0;
        scale = 1;
        shift = 0;
        // create matrix
        for(i=0;i<8;i=i+1) begin
            for(j=0;j<8;j=j+1) begin
                w[i][j] = (i*3-j*2) % 15 -7;
                a[i][j] = (j*2-i) % 11 -5;
            end
        end
        // matrix w
        $display("       | %d %d %d %d %d %d %d %d |", w[0][0], w[0][1], w[0][2], w[0][3], w[0][4], w[0][5], w[0][6], w[0][7]);
        $display("       | %d %d %d %d %d %d %d %d |", w[1][0], w[1][1], w[1][2], w[1][3], w[1][4], w[1][5], w[1][6], w[1][7]);
        $display("       | %d %d %d %d %d %d %d %d |", w[2][0], w[2][1], w[2][2], w[2][3], w[2][4], w[2][5], w[2][6], w[2][7]);
        $display("       | %d %d %d %d %d %d %d %d |", w[3][0], w[3][1], w[3][2], w[3][3], w[3][4], w[3][5], w[3][6], w[3][7]);
        $display(" w =   | %d %d %d %d %d %d %d %d |", w[4][0], w[4][1], w[4][2], w[4][3], w[4][4], w[4][5], w[4][6], w[4][7]);
        $display("       | %d %d %d %d %d %d %d %d |", w[5][0], w[5][1], w[5][2], w[5][3], w[5][4], w[5][5], w[5][6], w[5][7]);
        $display("       | %d %d %d %d %d %d %d %d |", w[6][0], w[6][1], w[6][2], w[6][3], w[6][4], w[6][5], w[6][6], w[6][7]);
        $display("       | %d %d %d %d %d %d %d %d |", w[7][0], w[7][1], w[7][2], w[7][3], w[7][4], w[7][5], w[7][6], w[7][7]);
        // matrix a
        $display("========================================================================");

        $display("       | %d %d %d %d %d %d %d %d |", a[0][0], a[0][1], a[0][2], a[0][3], a[0][4], a[0][5], a[0][6], a[0][7]);
        $display("       | %d %d %d %d %d %d %d %d |", a[1][0], a[1][1], a[1][2], a[1][3], a[1][4], a[1][5], a[1][6], a[1][7]);
        $display("       | %d %d %d %d %d %d %d %d |", a[2][0], a[2][1], a[2][2], a[2][3], a[2][4], a[2][5], a[2][6], a[2][7]);
        $display("       | %d %d %d %d %d %d %d %d |", a[3][0], a[3][1], a[3][2], a[3][3], a[3][4], a[3][5], a[3][6], a[3][7]);
        $display(" a =   | %d %d %d %d %d %d %d %d |", a[4][0], a[4][1], a[4][2], a[4][3], a[4][4], a[4][5], a[4][6], a[4][7]);
        $display("       | %d %d %d %d %d %d %d %d |", a[5][0], a[5][1], a[5][2], a[5][3], a[5][4], a[5][5], a[5][6], a[5][7]);
        $display("       | %d %d %d %d %d %d %d %d |", a[6][0], a[6][1], a[6][2], a[6][3], a[6][4], a[6][5], a[6][6], a[6][7]);
        $display("       | %d %d %d %d %d %d %d %d |", a[7][0], a[7][1], a[7][2], a[7][3], a[7][4], a[7][5], a[7][6], a[7][7]);
        // compute 
        for(i=0;i<8;i=i+1) begin
            for(j=0;j<8;j=j+1) begin
                expected_acc[i][j] = 0;
                for(k=0;k<8;k=k+1) begin
                    expected_acc[i][j] = expected_acc[i][j] + w[i][k] * a[k][j];
                end
                scaled_t = $signed(expected_acc[i][j]) * $signed({1'b0, scale});
                scaled_t = scaled_t >>> shift;
                if(scaled_t > 127) expected_out[i][j] = 8'sd127;
                else if(scaled_t < -128) expected_out[i][j] = -8'sd128;
                else expected_out[i][j] = scaled_t[7:0]; 
            end
        end
        @(negedge clk); rst = 0;
        load_matrix;
        @(negedge clk); start = 1;
        @(negedge clk); start = 0;
        count_cycle = 0;
        while (!done && count_cycle < 100) begin
            @(posedge clk);
            count_cycle = count_cycle + 1;
        end
        $display("count_cycle = %d", count_cycle);
        $display("done = %b", done);
        count_fail = 0;
        for(i=0;i<8;i=i+1) begin
            for(j=0;j<8;j=j+1) begin
                if(expected_out[i][j] !== result[i][j]) begin
                    count_fail = count_fail + 1;
                    $display("count_fail = %d", count_fail);
                    $display("FAIL [%d] [%d], got = %d, expected = %d, acc = %d", i, j, result[i][j], expected_out[i][j], expected_acc[i][j]);             
                end
                else $display("PASS [%d] [%d], got = %d, expected = %d, acc = %d", i, j, result[i][j], expected_out[i][j], expected_acc[i][j]);
            end
        end
    end
endmodule