module main_decoder(
    input  logic [6:0] opcode,
    output logic       branch,
    output logic       jump,
    output logic       jalr,
    output logic       alusrc,
    output logic       regwrite,
    output logic       memwrite,
    output logic [1:0] resultsrc,
    output logic [2:0] immsrc,
    output logic [1:0] aluop
);

    always_comb begin
        // defaults
        branch    = 0;
        jump      = 0;
        jalr      = 0;
        alusrc    = 0;
        regwrite  = 0;
        memwrite  = 0;
        immsrc    = 3'b000;
        aluop     = 2'b00;
        resultsrc = 2'b00;

        case (opcode)
            7'b0110011: begin // R-type
                alusrc   = 0;
                regwrite = 1;
                aluop    = 2'b10;
                resultsrc = 2'b00;
            end

            7'b0010011: begin // I-type ALU (ADDI, ANDI...)
                alusrc   = 1;
                regwrite = 1;
                immsrc   = 3'b000; // I-type
                aluop    = 2'b11;
                resultsrc = 2'b00;
            end

            7'b0000011: begin // Load (LW)
                alusrc   = 1;
                regwrite = 1;
                immsrc   = 3'b000; // I-type
                aluop    = 2'b00;
                resultsrc = 2'b01; // from memory
            end

            7'b0100011: begin // Store (SW)
                alusrc   = 1;
                memwrite = 1;
                immsrc   = 3'b001; // S-type
                aluop    = 2'b00;
                resultsrc = 2'b00;
            end

            7'b1100011: begin // Branch (BEQ, BNE - basic)
                branch   = 1;
                immsrc   = 3'b010; // B-type
                aluop    = 2'b01;
            end

            7'b1101111: begin // JAL
                jump      = 1;
                regwrite  = 1;      // write x[rd] = PC+4
                immsrc    = 3'b011; // J-type
                resultsrc = 2'b10;  // PC+4
            end

            7'b1100111: begin // JALR
                jump      = 1;
                jalr      = 1;
                regwrite  = 1;      // link
                alusrc    = 1;      // JALR uses RS1 + imm
                immsrc    = 3'b000; // I-type
                resultsrc = 2'b10;  // PC+4
            end

            7'b0110111: begin // LUI
                regwrite  = 1;
                immsrc    = 3'b100; // U-type
                aluop     = 2'b00;
                resultsrc = 2'b00;
            end

            default: begin
                // keep defaults
            end
        endcase
    end

endmodule
