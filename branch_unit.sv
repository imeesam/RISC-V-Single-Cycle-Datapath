module branch_unit (
    input  logic branch,
    input  logic jump,
    input  logic jalr,
    input  logic zero,
    input  logic [31:0] pc,
    input  logic [31:0] immext,
    input  logic [31:0] rs1,
    output logic [31:0] pc_target,
    output logic        take_branch
);
    assign take_branch = branch & zero;

    always_comb begin
        if (jalr)
            pc_target = rs1 + immext; // JALR uses RS1 + imm
        else
            pc_target = pc + immext;  // J-type and B-type target = PC + imm
    end
endmodule
