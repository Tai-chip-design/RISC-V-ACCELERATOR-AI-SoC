module pe (
    input clk, rst, clear, enable,
    input signed [7:0] weight, activation,
    output reg signed [7:0] weight_out, 
    output reg signed [7:0] activation_out,
    output reg signed [31:0] acc_out
);
    wire signed [15:0] result;
    assign result = weight * activation;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            weight_out <= 0;
            activation_out <= 0;
            acc_out <= 0;
        end
        else if(clear) acc_out <= 0;
        else if(enable) begin
            weight_out <= weight;
            activation_out <= activation;
            acc_out <= acc_out + result;
        end
    end
endmodule