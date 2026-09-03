module tb_mmio_bus;
    reg clk, rst;
    reg [31:0] cpu_addr, cpu_writedata;
    reg cpu_memwrite;
    wire [31:0] cpu_readdata;
    wire start, weight_load, activation_load;
    wire [2:0] load_row, load_col;
    wire signed [31:0] scale;
    wire [4:0] shift;
    wire signed [7:0] weight_data, activation_data;
    reg busy, done;
    reg signed [7:0] result [0:7][0:7];
    mmio_bus dut(
        .clk(clk),
        .rst(rst),
        .cpu_addr(cpu_addr),
        .cpu_writedata(cpu_writedata),
        .cpu_memwrite(cpu_memwrite),
        .cpu_readdata(cpu_readdata),
        .start(start),
        .weight_load(weight_load),
        .activation_load(activation_load),
        .load_row(load_row),
        .load_col(load_col),
        .scale(scale),
        .shift(shift),
        .weight_data(weight_data),
        .activation_data(activation_data),
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
    integer i, j, fail_count;
    initial begin
        rst = 1;
        cpu_addr = 0;
        cpu_writedata = 0;
        cpu_memwrite = 0;
        busy = 0;
        done = 0;
        for(i=0;i<8;i=i+1) begin
            for(j=0;j<8;j=j+1) begin
                result[i][j] = i*8 + j -31;
            end
        end
        @(posedge clk);
        rst = 0; 
        fail_count = 0;
        // test 1: write ctrl
        @(posedge clk);
        cpu_addr = 32'h1000;;
        cpu_writedata = 1;
        cpu_memwrite = 1;
        @(posedge clk);
        cpu_memwrite = 0;
        if(start !== 0) begin
            $display("FAIL : start = %d", start);
            fail_count = fail_count + 1;
        end
        else $display("PASS : start = %d", start);
        // Test 2: read status
        busy = 1; done = 0; cpu_addr = 32'h1004; #1;
        if(cpu_readdata !== 32'h1) begin
            $display("FAIL cpu_readdata = %h, busy = %d, done = %d", cpu_readdata, busy, done);
            fail_count = fail_count + 1;
        end 
        else $display("PASS cpu_readdata = %h, busy = %d, done = %d", cpu_readdata, busy, done);
        // Test 3: ghi weight[3][5]
        cpu_memwrite = 1;
        cpu_addr = 32'h2000 + 3*32 + 5*4;
        cpu_writedata = -8'sd42;
        @(posedge clk);
        cpu_memwrite = 0;
        #1;
        if(load_row !== 3 || load_col !== 5 || weight_data !== -8'sd42) begin
            $display("FAIL load_row = %d, load_col = %d, weight_data = %d", load_row, load_col, weight_data);
            fail_count = fail_count + 1;
        end
        else 
            $display("PASS load_row = %d, load_col = %d, weight_data = %d", load_row, load_col, weight_data);
        // test 4 read result[2][6]
        cpu_addr = 32'h4000 + 2*32 + 6*4;
        #1;
        if($signed(cpu_readdata[7:0]) !== result[2][6]) begin
            $display("FAIL cpu_readdata[7:0] = %d, result = %d", cpu_readdata[7:0], result[2][6]);
            fail_count = fail_count + 1;
        end
        else $display("PASS cpu_readdata[7:0] = %d, result = %d", cpu_readdata[7:0], result[load_row][load_col]);
        // test 5 write adrr error
        cpu_addr = 32'hffffffff;
        #1;
        if(cpu_readdata !== 32'hDEADBEEF) begin
            $display("FAIL cpu_readdata = %h", cpu_readdata);
            fail_count = fail_count + 1;
        end
        else $display("PASS cpu_readdata = %h", cpu_readdata);
        if(fail_count == 0) begin
            $display("PASS");
        end
        else $display("FAIL");
        $stop;
    end
endmodule