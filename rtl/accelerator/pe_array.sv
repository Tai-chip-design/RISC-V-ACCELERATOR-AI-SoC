module pe_array (
    input clk, rst, enable, clear,
    input signed [7:0] weight [0:7],
    input signed [7:0] activation [0:7],
    output signed [31:0] acc_out [0:7][0:7]
);
    wire signed [7:0] w_reg [0:7][0:8];
    wire signed [7:0] a_reg [0:8][0:7];
    genvar i, j;
    generate
        for(i=0;i<8;i++) begin
            assign w_reg[i][0] = weight[i];
        end
        for(j=0;j<8;j++) begin
            assign a_reg[0][j] = activation[j];
        end
        for(i=0;i<8;i++)begin
            for(j=0;j<8;j++)begin
                pe array(.clk(clk), 
                        .rst(rst), 
                        .enable(enable), 
                        .clear(clear), 
                        .weight(w_reg[i][j]), 
                        .activation(a_reg[i][j]),
                        .weight_out(w_reg[i][j+1]),
                        .activation_out(a_reg[i+1][j]),
                        .acc_out(acc_out[i][j])
                     );
            end
        end
    endgenerate 
endmodule