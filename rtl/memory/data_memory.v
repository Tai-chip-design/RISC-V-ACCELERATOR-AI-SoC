module data_memory (
    input [31:0] a, wd,
    input we, clk,
    output wire [31:0] rd
);
    reg [31:0] ram [63:0];
    assign rd = ram[a[7:2]];
    always @(posedge clk) begin
        if(we) ram[a[7:2]] <= wd;
    end 
endmodule