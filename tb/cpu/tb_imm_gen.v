`timescale 1ns/1ps
module tb_imm_gen;
    reg [31:0] instr;
    wire [31:0] imm;
    imm_gen dut(
        .instr(instr),
        .imm(imm)
    );
    initial begin
        instr = 0; 
        // test 1 I-type
        instr[31:20] = 12'd10; // immediate
        instr[19:15] = 5'd6; // x6
        instr[14:12] = 3'b000; // funct3
        instr[11:7] = 5'd5; // x5
        instr[6:0] = 7'b0010011; // opcode
        #10;
        $display("TEST 1 : I-type");
        $display("instr = %h", instr);
        $display("imm = %h", imm);
        if(imm == 32'd10) $display("PASS");
        else $display("FAIL");
        // test 2 I-type with number nagative
        instr = 0;
        instr[31:20] = 12'b111111111011; // immediate
        instr[19:15] = 5'd6; // x6
        instr[14:12] = 3'b000; // funct3
        instr[11:7] = 5'd5; // x5
        instr[6:0] = 7'b0010011; // opcode
        #10;
        $display("TEST 2 : I-type");
        $display("instr = %h", instr);
        $display("imm = %h", imm);
        if(imm == 32'hfffffffb) $display("PASS");
        else $display("FAIL");
        // test 3 S-type
        instr = 0;
        instr[31:25] = 7'b0000000;
        instr[11:7] = 5'd20;
        instr[24:20] = 5'd6;
        instr[19:15] = 5'd5;
        instr[14:12] = 3'b010;
        instr[6:0] = 7'b010011;
        #10;
        $display("TEST 3 S-type");
        $display("instr = %h", instr);
        $display("imm = %h", imm);
        if(imm == 32'd20) $display("PASS");
        else $display("FAIL");
        // TEST 4 B-type
        instr = 0;
        instr[31] = 1'b0;
        instr[7] = 1'b0;
        instr[30:25] = 6'b000000;
        instr[11:8] = 4'b1000; // immediate
        instr[24:20] = 5'd6; // rs2
        instr[19:15] = 5'd5; // rs1
        instr[14:12] = 3'b000; // beq
        instr[6:0] = 7'b1100011;  // opcode
        #10;
        $display("TEST B-type");
        $display("instr = %h", instr);
        $display("imm = %h", imm);
        if(imm == 31'd16) $display("PASS");
        else $display("FAIL");
        // TEST 5 U-type
        instr = 0;
        instr[31:12] = 20'h12345;
        instr[11:7] = 5'd5;
        instr[6:0] = 7'b0110111;
        #10;
        $display("TEST U-type");
        $display("instr = %h", instr);
        $display("imm = %h", imm);
        if(imm == 32'h12345000) $display("PASS");
        else $display("FAIL");
        // TEST 6 J-type
        instr = 0;
        instr[31] = 0;
        instr[19:12] = 8'b00000000;
        instr[20] = 1'b0;
        instr[30:21] = 10'b0000001000;
        instr[11:7] = 5'd5; 
        instr[6:0] = 7'b1101111;
        #10;
        $display("TEST J-type");
        $display("instr = %h",instr);
        $display("imm = %h", imm);
        if(imm == 32'd16) $display("PASS");
        else $display("FAIL");
        $stop;
    end
endmodule