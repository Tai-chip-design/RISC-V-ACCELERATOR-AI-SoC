module tb_pe_array;
    reg clk, rst, enable, clear;
    reg signed [7:0] weight [0:7];
    reg signed [7:0] activation [0:7];
    wire signed [31:0] acc_out [0:7][0:7];
    pe_array dut(
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear(clear),
        .weight(weight),
        .activation(activation),
        .acc_out(acc_out)
    );
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end
    integer i,j,k,t;
    reg signed [7:0] w [0:7][0:7];
    reg signed [7:0] a [0:7][0:7]; 
    integer expected [0:7][0:7];
    integer errors = 0;
    initial begin
        rst = 1;
        enable = 0;
        clear = 0;
        for(i=0;i<8;i++) begin
            weight[i] = 0;
            activation[i] = 0;
        end
        // create matrix
        for(i=0;i<8;i++) begin
            for(j=0;j<8;j++) begin
                w[i][j] = i - j;
                a[i][j] = (i+j) % 5 -2;
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
        // compute component of matrix
        for(i=0;i<8;i++) begin
            for(j=0;j<8;j++) begin
                expected[i][j] = 0;
                for(k=0;k<8;k++) begin
                    expected[i][j] = expected[i][j] + w[i][k] * a[k][j];
                end
            end
        end
        @(posedge clk);
        rst = 0; enable = 1; clear = 1;
        @(posedge clk);
        clear = 0;
        // skew time
        for(t=0;t<15;t++) begin
            for(i=0;i<8;i++)begin
                k = t - i;
                weight[i] = (k>=0 && k<8) ? w[i][k] : 0;
            end
            for(j=0;j<8;j++) begin
                k = t - j;
                activation[j] = (k>=0 && k < 8) ? a[k][j] : 0;
            end
            @(posedge clk);
        end
        for(i=0;i<8;i++) begin
            weight[i] = 0;
            activation[i] = 0;
        end
        repeat(10) @(posedge clk);
        for(i=0;i<8;i++) begin
            for(j=0;j<8;j++) begin
                if(acc_out[i][j] !== expected[i][j]) begin
                    $display("Fail [%d][%d] : got = %d, expected = %d", i, j, acc_out[i][j], expected[i][j]);
                    errors = errors + 1;
                end
                else begin
                    $display("PASS [%d][%d] : got = %d, expected = %d", i, j, acc_out[i][j], expected[i][j]);
                end
            end
        end
        $display("error numbers = %d", errors);
        if(errors == 0) $display("PASS");
        else $display("FAIL");
        $stop;
    end
endmodule