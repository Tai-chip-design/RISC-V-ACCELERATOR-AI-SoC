module soc_top (
    input clk, rst
);
    wire [31:0] instr, readdata, pc, aluout, writedata;
    wire memwrite;
    riscv_processor cpu(.clk(clk), .rst(rst), .instr(instr), .readdata(readdata), .pc(pc), .aluout(aluout), .writedata(writedata), .memwrite(memwrite));
    instruction_memory im(.pc(pc), .instr(instr));
    // suppose if addr > 32'h1000 is mmio else ram
    wire is_mmio;
    assign is_mmio = (aluout >= 32'h1000);
    wire [31:0] readdata_ram, readdata_mmio;
    data_memory dm(.a(aluout), .wd(writedata), .we(memwrite && !is_mmio), .clk(clk), .rd(readdata_ram));
    // mmio bus
    wire start, weight_load, activation_load, busy, done;
    wire signed [31:0] scale;
    wire [4:0] shift;
    wire [2:0] load_row, load_col;
    wire signed [7:0] weight_data, activation_data;
    wire signed [7:0] result [0:7][0:7];
    mmio_bus mmio(.clk(clk), .rst(rst), .cpu_addr(aluout), .cpu_writedata(writedata), .cpu_memwrite(memwrite), .cpu_readdata(readdata_mmio), .start(start), .scale(scale), .shift(shift), .weight_load(weight_load), .activation_load(activation_load), .load_row(load_row), .load_col(load_col), .weight_data(weight_data), .activation_data(activation_data), .busy(busy), .done(done), .result(result));
    accel_top accel(.clk(clk), .rst(rst), .start(start), .weight_data(weight_data), .activation_data(activation_data), .load_row(load_row), .load_col(load_col), .weight_load(weight_load), .activation_load(activation_load), .scale(scale), .shift(shift), .busy(busy), .done(done), .result(result));
    // choose readdata return to cpu
    assign readdata = is_mmio ? readdata_mmio : readdata_ram;

endmodule