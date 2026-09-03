module requantize (
    input signed [31:0] acc_in,
    input signed [31:0] scale,
    input [4:0] shift,
    output reg signed [7:0] out_int8
);
    reg signed [63:0] scaled;
    always @(*) begin
        scaled = acc_in * $signed({1'b0, scale});
        scaled = scaled >>> shift;
        if(scaled > 127) out_int8 = 8'd127;
        else if(scaled < -128) out_int8 = -8'sd128;
        else out_int8 = scaled[7:0];
    end
endmodule