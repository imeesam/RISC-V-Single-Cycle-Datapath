module data_memory(
    input  logic        clk,
    input  logic        memwrite,
    input  logic [31:0] addr,   // byte address
    input  logic [31:0] wd,     // write data
    output logic [31:0] rd      // read data
);

    logic [7:0] mem [0:255];

    assign rd = {mem[addr + 3], mem[addr + 2], mem[addr + 1], mem[addr]};

    always_ff @(posedge clk) begin
        if (memwrite) begin
            mem[addr]     <= wd[7:0];
            mem[addr + 1] <= wd[15:8];
            mem[addr + 2] <= wd[23:16];
            mem[addr + 3] <= wd[31:24];
        end
    end
endmodule