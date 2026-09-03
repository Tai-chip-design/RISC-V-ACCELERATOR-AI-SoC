module riscv_processor (
    input clk, rst,
    input [31:0] instr,
    input [31:0] readdata,
    output [31:0] pc,
    output [31:0] aluout,
    output [31:0] writedata,
    output memwrite
);
    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd = instr[11:7];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [6:0] funct7 = instr[31:25];
    //signal control 
    wire reg_write, mem_write, mem_to_reg, alu_src, branch, branch_ne, jumb, lui;
    wire [3:0] alu_control;
    control_unit cu(.opcode(opcode), .funct3(funct3), .funct7(funct7), .reg_write(reg_write), .mem_write(mem_write), .mem_to_reg(mem_to_reg), .alu_src(alu_src), .branch(branch), .branch_ne(branch_ne), .jumb(jumb), .lui(lui), .alu_control(alu_control));
    assign memwrite = mem_write;
    // immediate
    wire [31:0] imm;
    imm_gen ig(.instr(instr), .imm(imm));
    // register_file
    wire [31:0] rd1, rd2, result;
    register_file rf(.clk(clk), .rs1(rs1), .rs2(rs2), .rd(rd), .we(reg_write), .wd(result), .rd1(rd1), .rd2(rd2));
    assign writedata = rd2;
    // alu 
    wire [31:0] alu_b;
    wire [31:0] alu_result;
    wire zero;
    assign alu_b = alu_src ? imm : rd2;
    alu a(.a(rd1), .b(alu_b), .alu_control(alu_control), .result(alu_result), .zero(zero));
    assign aluout = alu_result;
    // write back register_file include instructions such as JAL, LUI, LW, ALU
    wire [31:0] pc_plus;
    assign pc_plus = pc + 4;
    assign result = lui ? imm : jumb ? pc_plus : mem_to_reg ? readdata : alu_result;
    // pc logic
    reg [31:0] pc_reg;
    wire take_branch;
    assign take_branch = branch && (branch_ne ? !zero : zero);
    wire [31:0] pc_next;
    assign pc_next = jumb ? (pc_reg + imm) : take_branch ? (pc_reg + imm) : pc_plus;
    always @(posedge clk or posedge rst) begin
        if(rst) pc_reg = 0;
        else pc_reg <= pc_next;
    end
    assign pc = pc_reg;
endmodule