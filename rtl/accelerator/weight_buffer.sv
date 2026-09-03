module weight_buffer (
    input clk,
    input load,
    input [2:0] load_col, load_row,
    input [4:0] t,
    input signed [7:0] load_data,
    output reg signed [7:0] weight_out [0:7]
);
    reg signed [7:0] mem [0:7][0:7];
    integer i, k;
    always @(posedge clk) begin
        if(load) begin
            mem[load_row][load_col] <= load_data;
        end
    end 
    always @(*) begin
        for(i=0;i<8;i++) begin
            k = t - i;
            weight_out[i] = (k>=0 && k<8) ? mem[i][k] : 0;
        end
    end
endmodule