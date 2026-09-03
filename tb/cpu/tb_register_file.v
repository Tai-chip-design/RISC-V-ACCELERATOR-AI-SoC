`timescale 1ns/1ps
module tb_register_file;
    reg clk;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] wd;
    reg we;
    wire [31:0] rd1, rd2;
    register_file dut(
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wd),
        .we(we),
        .rd1(rd1),
        .rd2(rd2)
    );    
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end 
    initial begin
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        wd = 0;
        we = 0;
        #10;
        // test 1 read x0
        $display("TEST READ X0");
        $display("X0 = %h", rd);
        if(rd==0) $display("PASS");
        else $display("FAIL");
        // test 2 write x1
        #2;
        rd = 5'd1;
        we = 1;
        wd = 32'h0000007a;
        #8;
        we = 0;
        rs1 = 5'd1; // read rs1
        #2;
        $display("rd1 = %h", rd1);
        if(rd1 == 32'h0000007a) $display("PASS");
        else $display("FAIL");
        // TEST 3 write x2
        #2;
        rd = 5'd2;
        we = 1;
        wd = 32'h12300045;
        #8;
        we = 0;
        rs2 = 5'd2; // read rs1
        #2;
        $display("rd2 = %h", rd2);
        if(rd2 == 32'h12300045) $display("PASS");
        else $display("FAIL");
        // TEST 4 read rd1, rd2
        rs1 = 5'd1;
        rs2 = 5'd2;
        #2;
        $display("rd1 = %h", rd1);
        $display("rd2 = %h", rd2);
        if(rd1 == 32'h0000007a && rd2 == 32'h12300045) $display("PASS");
        else $display("FAIL");
        #2;
        rd = 5'd0;
        wd = 32'h00010203;
        we = 1;
        #8;
        we = 0;
        rs1 = 5'd0;
        #2;
        $display("rd1 = %h", rd1);
        if(rd1 == 32'b0) $display("PASS");
        else $display("FAIL");
        $stop;
    end 
endmodule