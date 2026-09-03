`timescale 1ns/1ps
module tb_soc_top;
    reg clk, rst;
    soc_top dut(
        .clk(clk),
        .rst(rst)
    );
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end
    integer fail_count;
    reg [31:0] rdata;
    task force_write(input [31:0] addr, input [31:0] data);
        begin
            force dut.aluout = addr;
            force dut.writedata = data;
            force dut.memwrite = 1;
            @(posedge clk);
            force dut.memwrite = 0;
        end
    endtask
    task force_read(input [31:0] addr, output [31:0] data);
        begin
           force dut.aluout = addr;
           force dut.memwrite = 0;
           #1;
           data = dut.readdata; 
        end
    endtask
    initial begin
        rst = 1;
        fail_count = 0;
        @(posedge clk);
        rst = 0;
        // test 1: read/write Ram (addr < 0x1000)
        force_write(32'h0010, 32'hAABBCCDD);
        force_read(32'h0010, rdata);
        if(rdata !== 32'hAABBCCDD) begin
            $display("FAIL got = %h, expected = AABBCCDD", rdata);
            fail_count = fail_count + 1;
        end
        else $display("PASS got = %h, expected = AABBCCDD", rdata);
        // test 2: write mmio to check data 
        force_write(32'h1000, 32'h1);
        force_read(32'h0010, rdata);
        if(rdata !== 32'hAABBCCDD) begin
            $display("FAIL got = %h, wrote into ram", rdata);
            fail_count = fail_count + 1;
        end
        else $display("PASS got = %h, no write into ram", rdata);
        // test 3: read status
        force_read(32'h1004, rdata);
        if(rdata[0] !== 1'b1) begin
            $display("FAIL no busy, busy = %b", rdata[0]);
            fail_count = fail_count + 1;
        end
        else $display("PASS busy, busy = %b", rdata[0]);
        // test 4 write weight[0][0], ram still unchanged
        force_write(32'h2000, -8'sd10);
        force_read(32'h0010, rdata);
        if(rdata !== 32'hAABBCCDD) begin
            $display("FAIL got = %h, wrote into ram", rdata);
            fail_count = fail_count + 1;
        end
        else $display("PASS got = %h, no write into ram", rdata);
        release dut.aluout;
        release dut.writedata;
        release dut.memwrite;
        if(fail_count == 0) begin
            $display("PASS");
        end
        else $display("FAIL");
        $stop;
    end
endmodule