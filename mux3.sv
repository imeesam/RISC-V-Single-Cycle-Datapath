module mux3 #(parameter WIDTH = 32)(
    input  logic [WIDTH-1:0] d0, // ALU result
    input  logic [WIDTH-1:0] d1, // Memory read
    input  logic [WIDTH-1:0] d2, // PC+4 (for JAL/JALR)
    input  logic [1:0]        s,  // resultsrc
    output logic [WIDTH-1:0]  y
);
    always_comb begin
        case (s)
            2'b00: y = d0;
            2'b01: y = d1;
            2'b10: y = d2;
            default: y = d0;
        endcase
    end
endmodule
