module tb_top_cpu;
    reg clk, rst;
    wire [31:0] writedata, dataadr;
    wire memwrite;
    top_cpu dut(
        .clk(clk),
        .rst(rst),
        .writedata(writedata),
        .dataadr(dataadr),
        .memwrite(memwrite)
    );
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end
    initial begin
        rst = 1; #12;
        rst = 0; #80;
        $display("x1 = %d", dut.datapath.rf.rf[1]);
        $display("x2 = %d", dut.datapath.rf.rf[2]);
        $display("x3 = %d", dut.datapath.rf.rf[3]);
        $display("x4 = %d", dut.datapath.rf.rf[4]);
        $display("x5 = %d", dut.datapath.rf.rf[5]);
        $display("x6 = %d", dut.datapath.rf.rf[6]);
        $display("x7 = %d", dut.datapath.rf.rf[7]);
        #10; $stop;
    end
    initial begin
        $monitor("time = %0t | pc = %h | instr = %h | aluout = %d | writedata = %d | memwrite = %b", $time, dut.datapath.pc, dut.datapath.instr, dataadr,  writedata, memwrite);
    end
endmodule