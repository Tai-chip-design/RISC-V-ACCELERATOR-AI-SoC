module mmio_bus (
    input rst, clk,
    // bus CPU
    input [31:0] cpu_addr,
    input [31:0] cpu_writedata,
    input cpu_memwrite,
    output reg [31:0] cpu_readdata,
    // bus accele AI
    output reg start,
    output reg signed [31:0] scale,
    output reg [4:0] shift,
    output reg weight_load,
    output reg activation_load,
    output reg [2:0] load_row,
    output reg [2:0] load_col,
    output reg signed [7:0] weight_data,
    output reg signed [7:0] activation_data,
    input busy, done,
    input signed [7:0] result [0:7][0:7]
);
    // address table
    parameter addr_ctrl = 32'h1000;
    parameter addr_status = 32'h1004;
    parameter addr_scale = 32'h1008;
    parameter addr_shift = 32'h100c;
    parameter addr_weight = 32'h2000; // 0x2000-0x20fc (8x8, 4byte/tu)
    parameter addr_activation = 32'h3000; // 0x3000-0x30fc
    parameter addr_result = 32'h4000; // 0x4000-0x40fc
    // compute row/col
    wire in_weight_range;
    wire in_activation_range;
    wire in_result_range;
    assign in_weight_range = (cpu_addr >= addr_weight && cpu_addr < addr_weight + 256);
    assign in_activation_range = (cpu_addr >= addr_activation && cpu_addr < addr_activation + 256);
    assign in_result_range = (cpu_addr >= addr_result && cpu_addr < addr_result + 256);
    wire [7:0] weight_offset, activation_offset, result_offset;
    wire [2:0] weight_row, weight_col, activation_row, activation_col, result_row, result_col;
    assign weight_offset = cpu_addr - addr_weight;
    assign activation_offset = cpu_addr - addr_activation;
    assign result_offset = cpu_addr - addr_result;
    assign weight_row = weight_offset[7:5];
    assign weight_col = weight_offset[4:2];
    assign activation_row = activation_offset[7:5];
    assign activation_col = activation_offset[4:2];
    assign result_row = result_offset[7:5];
    assign result_col = result_offset[4:2];
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            start <= 0;
            scale <= 1;
            shift <= 0;
            weight_load <= 0;
            activation_load <= 0;
            load_row <= 0;
            load_col <= 0;
            weight_data <= 0;
            activation_data <= 0;
        end
        else begin
            start <= 0;
            weight_load <= 0;
            activation_load <= 0;
            if(cpu_memwrite)begin
                if(cpu_addr == addr_ctrl) begin
                    start <= cpu_writedata[0];
                end
                else if(cpu_addr == addr_scale) begin
                    scale <= cpu_writedata;
                end
                else if (cpu_addr == addr_shift) begin
                    shift <= cpu_writedata[4:0];
                end
                else if(in_weight_range) begin
                    weight_load <= 1;
                    load_row <= weight_row;
                    load_col <= weight_col;
                    weight_data <= cpu_writedata[7:0];
                end
                else if (in_activation_range) begin
                    activation_load = 1;
                    load_row <= activation_row;
                    load_col <= activation_col;
                    activation_data <= cpu_writedata[7:0];
                end
            end
        end
    end
    // read
    always @(*) begin
        if(cpu_addr == addr_status) begin
            cpu_readdata <= {30'b0, done, busy};
        end
        else if (in_result_range) begin
            cpu_readdata <= {24'b0, result[result_row][result_col]};
        end
        else begin
            cpu_readdata <= 32'hDEADBEEF;
        end
    end
endmodule