module instruction_memory (
    input [31:0] pc,
    output [31:0] instr
);
    reg [31:0] ram [0:63];
    initial begin
        $readmemh("program.hex", ram);
    end
    assign instr = ram[pc[7:2]];
endmodule