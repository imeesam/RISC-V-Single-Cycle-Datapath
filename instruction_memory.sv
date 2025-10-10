module instruction_memory(
	input logic [31:0] addr,
	output logic [31:0] instr
);
logic [7:0] ram [0:255];

assign instr = {ram[addr+3],ram[addr+2],ram[addr+1],ram[addr]};

endmodule