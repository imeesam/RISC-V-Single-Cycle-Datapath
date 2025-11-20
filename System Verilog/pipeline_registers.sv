module pipeline_registers (
    input  logic clk, reset,
    input  logic [31:0] if_instr_in, if_pc_in,
    output logic [31:0] id_instr_out, id_pc_out
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            id_instr_out <= 32'b0;
            id_pc_out    <= 32'b0;
        end else begin
            id_instr_out <= if_instr_in;
            id_pc_out    <= if_pc_in;
        end
    end
endmodule
