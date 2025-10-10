module register_file (
    input  logic        clk,
    input  logic        regwrite,
    input  logic [4:0]  A1, A2, A3,     // register addresses
    input  logic [31:0] WD,             // write data
    output logic [31:0] RD1, RD2        // read data
);

    logic [31:0] REG [0:31];

    assign RD1 = REG[A1];
    assign RD2 = REG[A2];

    always_ff @(posedge clk) begin
        if (regwrite && (A3 != 5'd0))   // x0 is always 0 in RISC-V
            REG[A3] <= WD;
    end

    initial begin
        integer i;
        for (i = 0; i < 32; i = i + 1)
            REG[i] = 32'b0;
    end

endmodule
