module imm_extender(
    input  logic [2:0]  immsrc,
    input  logic [31:0] instr,
    output logic [31:0] Imm
);
    always_comb begin
        case (immsrc)
            3'b000: Imm = {{20{instr[31]}}, instr[31:20]};                                      // I-type
            3'b001: Imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};                          // S-type
            3'b010: Imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
            3'b011: Imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type
            3'b100: Imm = {instr[31:12], 12'b0};                                                 // U-type (LUI)
            default: Imm = 32'b0;
        endcase
    end
endmodule
