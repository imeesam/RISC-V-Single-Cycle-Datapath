module pc_ff(
    input  logic clk, reset,
    input  logic [31:0] d,
    output logic [31:0] q
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            q <= 32'b0;
        else
            q <= d;
    end
endmodule