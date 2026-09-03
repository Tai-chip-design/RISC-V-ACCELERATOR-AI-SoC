module top_cpu (
    input clk, rst,
    output [31:0] writedata, dataadr,
    output memwrite
);
    wire [31:0] instr, readdata, pc;
    riscv_processor datapath(.clk(clk), .rst(rst), .instr(instr), .readdata(readdata), .pc(pc), .aluout(dataadr), .writedata(writedata), .memwrite(memwrite));
    instruction_memory im(.pc(pc), .instr(instr));
    data_memory dm(.a(dataadr), .wd(writedata), .clk(clk), .we(memwrite), .rd(readdata));
endmodule