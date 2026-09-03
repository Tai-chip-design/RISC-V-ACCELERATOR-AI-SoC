module activation_buffer (
    input clk, load,
    input [2:0] load_col, load_row,
    input [4:0] t,
    input signed [7:0] load_data,
    output reg signed [7:0] activation_out [0:7]
);
    reg signed [7:0] mem [0:7][0:7];
    integer k, j;
    always @(posedge clk) begin
        if(load) begin
            mem[load_row][load_col] <= load_data;
        end
    end
    always @(*) begin
        for(j=0;j<8;j++) begin
            k = t - j;
            activation_out[j] = (k>=0 && k<8) ? mem[k][j] : 0;
        end
    end
endmodule