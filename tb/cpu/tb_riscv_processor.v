module tb_riscv_processor;
    reg clk, rst;
    reg [31:0] instr;
    reg [31:0] readdata;
    wire [31:0] pc;
    wire [31:0] aluout;
    wire [31:0] writedata;
    wire memwrite;
    riscv_processor dut(
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .readdata(readdata),
        .pc(pc),
        .aluout(aluout),
        .writedata(writedata),
        .memwrite(memwrite)
    );
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end
    initial begin
        rst = 1; 
        instr = 0;
        readdata = 0;
        #12;
        rst = 0;
        // ADDI x1, x0, 10
        // x1 = 10
        instr = 32'h00a00093;
        #10;
        // ADDI x2, x0, 20
        // x2 = 20
        instr = 32'h01400113;
        #10;
        // ADD x3, x1, x2
        // x3 = x1 + x2
        instr = 32'h002081b3;
        #10;
        // ADD x4, x1, x2
        // x4 = x1 + x2
        instr = 32'h00208233;
        #10;
        $stop;
    end
    initial begin
        $monitor("Time = %t | pc = %h | instr = %h | aluout = %d | writedata = %d | memwrite = %b", $time, pc, instr, aluout, writedata, memwrite);
    end
endmodule