module control_unit (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg reg_write, // signal enable write in register file
    output reg mem_write, // signal enable write in data memory
    output reg mem_to_reg, // writeback pick from alu or data_memory
    output reg alu_src, // signal to choose either rs2 or imm
    output reg [3:0] alu_control,
    output reg branch,
    output reg branch_ne,
    output reg jumb,
    output reg lui
);
    always @(*) begin
        reg_write = 0;
        mem_write = 0;
        mem_to_reg = 0;
        alu_src = 0;
        alu_control = 0;
        branch = 0;
        branch_ne = 0;
        jumb = 0;
        lui = 0;
        case (opcode)
            7'b0110011: begin // R_type
                reg_write = 1;
                case ({funct7,funct3})
                    10'b0000000_000: alu_control = 4'b0000; // add
                    10'b0100000_000: alu_control = 4'b0001; // sub
                    10'b0000000_111: alu_control = 4'b0010; // and
                    10'b0000000_110: alu_control = 4'b0011; // or
                    10'b0000000_100: alu_control = 4'b0100; // xor
                endcase
            end
            7'b0010011: begin // I_type
                alu_src = 1;
                reg_write = 1;
                case (funct3)
                    3'b000: alu_control = 4'b0000; // add
                    3'b111: alu_control = 4'b0010; // and
                    3'b110: alu_control = 4'b0011; // or
                    3'b100: alu_control = 4'b0100; // xor
                endcase
            end
            7'b0000011: begin // lw
                reg_write = 1; 
                alu_src = 1;
                mem_to_reg = 1;
                alu_control = 4'b0000;
            end
            7'b0100011: begin // sw
                alu_src = 1;
                mem_write = 1;
                alu_control = 4'b0000; 
            end
            7'b1100011: begin // BEQ/BNE
                branch = 1;
                alu_control = 4'b0001;
                branch_ne = (funct3 == 3'b001);    
            end
            7'b1101111: begin // JAL
                reg_write = 1;
                jumb = 1;
            end
            7'b0110111: begin // LUI
                reg_write = 1;
                lui = 1;
            end
        endcase
    end
endmodule