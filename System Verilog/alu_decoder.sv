module alu_decoder(
    input  logic [2:0] func3,
    input  logic [6:0] func7,
    input  logic [1:0] aluop,
    output logic [2:0] alucontrol
);

    always_comb begin
        case (aluop)
            2'b00: alucontrol = 3'b010; // add (loads/stores)
            2'b01: alucontrol = 3'b110; // sub (branches)
            2'b10: begin // R-type
                case ({func7, func3})
                    10'b0000000_000: alucontrol = 3'b010; // ADD
                    10'b0100000_000: alucontrol = 3'b110; // SUB
                    10'b0000000_111: alucontrol = 3'b000; // AND
                    10'b0000000_110: alucontrol = 3'b001; // OR
                    10'b0000000_100: alucontrol = 3'b011; // XOR
                    10'b0000000_001: alucontrol = 3'b100; // SLL (optional)
                    10'b0000000_101: alucontrol = 3'b101; // SRL (optional)
                    default:          alucontrol = 3'b010; // default ADD
                endcase
            end
            2'b11: alucontrol = 3'b010; // I-type arithmetic (ADDI, ...)
            default: alucontrol = 3'b010;
        endcase
    end

endmodule
