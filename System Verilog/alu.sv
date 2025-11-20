module alu (
    input  logic [31:0] a, b,          // operands
    input  logic [2:0]  alu_control,   // 3-bit ALU control input
    output logic [31:0] result,        // ALU result
    output logic        zero           // Zero flag (used for branches)
);

    always_comb begin
        unique case (alu_control)
            3'b000: result = a & b;                     // AND
            3'b001: result = a | b;                     // OR
            3'b010: result = a + b;                     // ADD
            3'b110: result = a - b;                     // SUB
            3'b111: result = ($signed(a) < $signed(b))  // SLT (Set Less Than)
                             ? 32'd1 : 32'd0;
            3'b011: result = a ^ b;                     // XOR (optional extra)
            default: result = 32'b0;                    // Default (safe)
        endcase
    end

    assign zero = (result == 32'b0);

endmodule
