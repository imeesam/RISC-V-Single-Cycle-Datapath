module control_unit(
    input  logic [6:0] opcode,
    input  logic [2:0] func3,
    input  logic [6:0] func7,
    input  logic       zero,
    output logic       pcsrc,
    output logic       alusrc,
    output logic       branch,
    output logic       jump,
    output logic       jalr,
    output logic       regwrite,
    output logic       memwrite,
    output logic [1:0] resultsrc,
    output logic [2:0] immsrc,
    output logic [2:0] alucontrol
);

    logic [1:0] aluop;

    // main decoder produces high-level control and aluop
    main_decoder maindec (
        .opcode(opcode),
        .branch(branch),
        .jump(jump),
        .jalr(jalr),
        .alusrc(alusrc),
        .regwrite(regwrite),
        .memwrite(memwrite),
        .resultsrc(resultsrc),
        .immsrc(immsrc),
        .aluop(aluop)
    );

    // alu decoder turns aluop + funct fields into exact ALU control
    alu_decoder aludec (
        .func3(func3),
        .func7(func7),
        .aluop(aluop),
        .alucontrol(alucontrol)
    );

    // PC source logic
    assign pcsrc = (branch & zero) | jump;

endmodule
