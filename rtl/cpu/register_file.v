module register_file (
    input clk,
    input [4:0] rs1, rs2, rd, // address resgister
    input [31:0] wd, //data writed in rd
    input we,
    output reg [31:0] rd1, rd2 // data read in registerfile
);
    reg [31:0] rf [0:31];
    assign rd1 = (rs1 != 0) ? rf[rs1] : 32'b0;
    assign rd2 = (rs2 != 0) ? rf[rs2] : 32'b0; 
    always @(posedge clk) begin
        if(we && rd!=0) rf[rd] <= wd;
    end
endmodule