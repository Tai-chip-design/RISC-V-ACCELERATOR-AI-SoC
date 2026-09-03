module tb_control_unit;
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;
    wire reg_write;
    wire mem_write;
    wire mem_to_reg;
    wire alu_src;
    wire [3:0] alu_control;
    wire branch;
    wire branch_ne;
    wire jumb;
    wire lui;
    control_unit dut(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .alu_control(alu_control),
        .branch(branch),
        .branch_ne(branch_ne),
        .jumb(jumb),
        .lui(lui)
    );
    initial begin
        // test case 1: R-type
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;
        $display("opcode = %b | funct3 = %b | funct7 = %b | reg_write = %b | mem_write = %b | mem_to_reg = %b | alu_src = %b | alu_control = %b | branch = %b | branch_ne = %b | jumb = %b | lui = %b", opcode, funct3, funct7, reg_write, mem_write, mem_to_reg, alu_src, alu_control, branch, branch_ne, jumb, lui);
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;
        $display("opcode = %b | funct3 = %b | funct7 = %b | reg_write = %b | mem_write = %b | mem_to_reg = %b | alu_src = %b | alu_control = %b | branch = %b | branch_ne = %b | jumb = %b | lui = %b", opcode, funct3, funct7, reg_write, mem_write, mem_to_reg, alu_src, alu_control, branch, branch_ne, jumb, lui);
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        #10;
        $display("opcode = %b | funct3 = %b | funct7 = %b | reg_write = %b | mem_write = %b | mem_to_reg = %b | alu_src = %b | alu_control = %b | branch = %b | branch_ne = %b | jumb = %b | lui = %b", opcode, funct3, funct7, reg_write, mem_write, mem_to_reg, alu_src, alu_control, branch, branch_ne, jumb, lui);
        funct3 = 3'b111;
        funct7 = 7'b0000000;
        #10;
        $display("opcode = %b | funct3 = %b | funct7 = %b | reg_write = %b | mem_write = %b | mem_to_reg = %b | alu_src = %b | alu_control = %b | branch = %b | branch_ne = %b | jumb = %b | lui = %b", opcode, funct3, funct7, reg_write, mem_write, mem_to_reg, alu_src, alu_control, branch, branch_ne, jumb, lui);
        funct3 = 3'b110;
        funct7 = 7'b0000000;
        #10;
        $display("opcode = %b | funct3 = %b | funct7 = %b | reg_write = %b | mem_write = %b | mem_to_reg = %b | alu_src = %b | alu_control = %b | branch = %b | branch_ne = %b | jumb = %b | lui = %b", opcode, funct3, funct7, reg_write, mem_write, mem_to_reg, alu_src, alu_control, branch, branch_ne, jumb, lui);
        funct3 = 3'b100;
        funct7 = 7'b0000000;
        #10;
        $display("opcode = %b | funct3 = %b | funct7 = %b | reg_write = %b | mem_write = %b | mem_to_reg = %b | alu_src = %b | alu_control = %b | branch = %b | branch_ne = %b | jumb = %b | lui = %b", opcode, funct3, funct7, reg_write, mem_write, mem_to_reg, alu_src, alu_control, branch, branch_ne, jumb, lui);
        // test case 2: I-type
        opcode = 7'b0010011;
        funct3 = 3'b000;
        #10;
        $display("opcode = %b | funct3 = %b | funct7 = %b | reg_write = %b | mem_write = %b | mem_to_reg = %b | alu_src = %b | alu_control = %b | branch = %b | branch_ne = %b | jumb = %b | lui = %b", opcode, funct3, funct7, reg_write, mem_write, mem_to_reg, alu_src, alu_control, branch, branch_ne, jumb, lui);
        funct3 = 3'b111;
        #10;
        $display("opcode = %b | funct3 = %b | funct7 = %b | reg_write = %b | mem_write = %b | mem_to_reg = %b | alu_src = %b | alu_control = %b | branch = %b | branch_ne = %b | jumb = %b | lui = %b", opcode, funct3, funct7, reg_write, mem_write, mem_to_reg, alu_src, alu_control, branch, branch_ne, jumb, lui);
        funct3 = 3'b110;
        #10;
        $display("opcode = %b | funct3 = %b | funct7 = %b | reg_write = %b | mem_write = %b | mem_to_reg = %b | alu_src = %b | alu_control = %b | branch = %b | branch_ne = %b | jumb = %b | lui = %b", opcode, funct3, funct7, reg_write, mem_write, mem_to_reg, alu_src, alu_control, branch, branch_ne, jumb, lui);
        funct3 = 3'b100;
        #10;
        $display("opcode = %b | funct3 = %b | funct7 = %b | reg_write = %b | mem_write = %b | mem_to_reg = %b | alu_src = %b | alu_control = %b | branch = %b | branch_ne = %b | jumb = %b | lui = %b", opcode, funct3, funct7, reg_write, mem_write, mem_to_reg, alu_src, alu_control, branch, branch_ne, jumb, lui);
        // test case 3: lw
        opcode = 7'b0000011;
        #10;
        $display("opcode = %b | funct3 = %b | funct7 = %b | reg_write = %b | mem_write = %b | mem_to_reg = %b | alu_src = %b | alu_control = %b | branch = %b | branch_ne = %b | jumb = %b | lui = %b", opcode, funct3, funct7, reg_write, mem_write, mem_to_reg, alu_src, alu_control, branch, branch_ne, jumb, lui);
        // test case 4 : sw
        opcode = 7'b0100011;
        #10;
        $display("opcode = %b | funct3 = %b | funct7 = %b | reg_write = %b | mem_write = %b | mem_to_reg = %b | alu_src = %b | alu_control = %b | branch = %b | branch_ne = %b | jumb = %b | lui = %b", opcode, funct3, funct7, reg_write, mem_write, mem_to_reg, alu_src, alu_control, branch, branch_ne, jumb, lui);
        // test case 5 : BEQ/BNE
        opcode = 7'b1100011;
        #10;
        $display("opcode = %b | funct3 = %b | funct7 = %b | reg_write = %b | mem_write = %b | mem_to_reg = %b | alu_src = %b | alu_control = %b | branch = %b | branch_ne = %b | jumb = %b | lui = %b", opcode, funct3, funct7, reg_write, mem_write, mem_to_reg, alu_src, alu_control, branch, branch_ne, jumb, lui);
        // test case 6 : JA
        opcode = 7'b1101111;
        #10;
        $display("opcode = %b | funct3 = %b | funct7 = %b | reg_write = %b | mem_write = %b | mem_to_reg = %b | alu_src = %b | alu_control = %b | branch = %b | branch_ne = %b | jumb = %b | lui = %b", opcode, funct3, funct7, reg_write, mem_write, mem_to_reg, alu_src, alu_control, branch, branch_ne, jumb, lui);
        // test case 7 : LUI
        opcode = 7'b0110111;
        #10;
        $display("opcode = %b | funct3 = %b | funct7 = %b | reg_write = %b | mem_write = %b | mem_to_reg = %b | alu_src = %b | alu_control = %b | branch = %b | branch_ne = %b | jumb = %b | lui = %b", opcode, funct3, funct7, reg_write, mem_write, mem_to_reg, alu_src, alu_control, branch, branch_ne, jumb, lui);
        $stop;
    end
    
endmodule