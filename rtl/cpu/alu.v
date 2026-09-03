module alu (
    input [31:0] a, b,
    input [3:0] alu_control,
    output reg [31:0] result,
    output wire zero
);
always @(*) begin
    case (alu_control)
        4'b0000: result = a + b; // ADD, ADDI, LW, SW
        4'b0001: result = a - b; // SUB, use for compare BEQ/BNE
        4'b0010: result = a & b; // AND, ANDI
        4'b0011: result = a | b; // OR, ORI
        4'b0100: result = a ^ b; // XOR, XORI
        default: result = 32'b0;
    endcase 
end
assign zero = (result == 0);
endmodule