module top_riscv (
    input  logic clk,
    input  logic reset
);
    // ----- core signals -----
    logic [31:0] pc, pc_next, pc_plus4, instr;
    logic [31:0] imm_ext;
    logic [31:0] rd1, rd2;            // regfile outputs
    logic [31:0] alu_b, alu_result;
    logic [31:0] mem_rd, write_data;
    logic [31:0] pc_target;
    logic [6:0]  opcode, funct7;
    logic [2:0]  funct3;
    logic zero, branch, jump, jalr;
    logic alusrc, regwrite, memwrite;
    logic [1:0] resultsrc;
    logic [2:0] immsrc;
    logic [2:0] alucontrol;
    logic pcsrc, take_branch;

    // ----- instruction memory -----
    instruction_memory IM (
        .addr(pc),
        .instr(instr)
    );

    // decode fields
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    // PC + 4
    assign pc_plus4 = pc + 32'd4;

    // immediate
    imm_extender IMM (
        .immsrc(immsrc),
        .instr(instr),
        .Imm(imm_ext)
    );

    // register file
    register_file RF (
        .clk(clk),
        .regwrite(regwrite),
        .A1(instr[19:15]),
        .A2(instr[24:20]),
        .A3(instr[11:7]),
        .WD(write_data),
        .RD1(rd1),
        .RD2(rd2)
    );

    // control unit (uses instr fields + ALU zero)
    control_unit CU (
        .opcode(opcode),
        .func3(funct3),
        .func7(funct7),
        .zero(zero),
        .pcsrc(pcsrc),
        .alusrc(alusrc),
        .branch(branch),
        .jump(jump),
        .jalr(jalr),
        .regwrite(regwrite),
        .memwrite(memwrite),
        .resultsrc(resultsrc),
        .immsrc(immsrc),
        .alucontrol(alucontrol)
    );

    // ALU input mux (reg_b or immediate)
    mux2 #(32) alu_src_mux (
        .d0(rd2),
        .d1(imm_ext),
        .sel(alusrc),
        .y(alu_b)
    );

    // ALU (3-bit control)
    alu ALU (
        .a(rd1),
        .b(alu_b),
        .alu_control(alucontrol),
        .result(alu_result),
        .zero(zero)
    );

    // Data memory (byte-addressable)
    data_memory DM (
        .clk(clk),
        .memwrite(memwrite),
        .addr(alu_result),
        .wd(rd2),
        .rd(mem_rd)
    );

    // Write-back mux (ALU / MEM / PC+4)
    mux3 #(32) result_mux (
        .d0(alu_result),
        .d1(mem_rd),
        .d2(pc_plus4),
        .s(resultsrc),
        .y(write_data)
    );

    // branch/jump target generator
    branch_unit BU (
        .branch(branch),
        .jump(jump),
        .jalr(jalr),
        .zero(zero),
        .pc(pc),
        .immext(imm_ext),
        .rs1(rd1),
        .pc_target(pc_target),
        .take_branch(take_branch)
    );

    // PC next selection (use pcsrc computed by CU)
    assign pc_next = pcsrc ? pc_target : pc_plus4;

    // PC register
    pc_ff PCREG (
        .clk(clk),
        .reset(reset),
        .d(pc_next),
        .q(pc)
    );

endmodule
