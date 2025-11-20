module toplvl_processor (
    input clk,
    input reset
);

    // === WIRE DECLARATIONS ===
    wire [31:0] pc, pcnext, pcplus4, pctarget;
    wire [31:0] instr;
    wire RegWrite, MemWrite, Branch, Jump, PCSrc;
    wire [1:0] ALUSrc, ResultSrc;
    wire [2:0] ImmSrc, ALUControl;
    wire [31:0] rd1, rd2;
    wire [31:0] imm;
    wire [31:0] srcA, srcB, alu_result;
    wire Zero;
    wire [31:0] read_data, result;

    // === I2C / Address Decoder Wires ===
    wire [31:0] addr_out1, addr_out2;
    wire [31:0] write_data_out1, write_data_out2;   // ? Added missing wire
    wire [31:0] i2c_read_data;
    wire scl_line, sda_line;

    // === Control flag to delay execution 1 cycle after reset
    reg exec_enable;

    always @(posedge clk or posedge reset) begin
        if (reset) exec_enable <= 0;
        else       exec_enable <= 1;
    end

    // === PC Module
    pc_cnt pc_register (
        .clk(clk),
        .reset(reset),
        .pcnext(pcnext),
        .pc(pc)
    );

    // === Instruction Memory
    instr_mem imem (
        .address(pc),
        .instruction(instr)
    );

    // === Control Unit
    control_unit cu (
        .opcode(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7(instr[31:25]),
        .Zero(Zero),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .ALUControl(ALUControl),
        .Jump(Jump),
        .PCSrc(PCSrc)
    );

    // === Register File
    reg_file rf (
        .clk(clk),
        .reg_write(RegWrite),
        .read_reg1(instr[19:15]),
        .read_reg2(instr[24:20]),
        .write_reg(instr[11:7]),
        .write_data(result),
        .read_data1(rd1),
        .read_data2(rd2)
    );

    // === Immediate Generator
    immem_ext imm_ext (
        .ImmSrc(ImmSrc),
        .Ins(instr),
        .Imm(imm)
    );

    // === ALU Inputs
    assign srcA = rd1;
    assign srcB =
        (ALUSrc == 2'b00) ? rd2 :
        (ALUSrc == 2'b01) ? imm :
        32'b0;

    // === ALU
    alu_1 alu (
        .a(srcA),
        .b(srcB),
        .ALUC(ALUControl),
        .c(alu_result)
    );

    assign Zero = (alu_result == 0);

    // === Address Decoder
    AddressDecoder_2Block decoder (
        .addr_in(alu_result),
        .write_data_in(rd2),
        .addr_out1(addr_out1),
        .addr_out2(addr_out2),
        .write_data_out1(write_data_out1),
        .write_data_out2(write_data_out2)   // ? Newly connected output
    );

    // === I2C Configurable Block (Block1)
    I2C_Configurable_Full i2c_master_slave (
        .clk(clk),
        .reset(reset),
        .addr_in(addr_out2),
        .write_data_in(write_data_out2),    // ? Connect write data
        .write_enable(MemWrite),
        .read_data_out(i2c_read_data),
        .scl(scl_line),
        .sda(sda_line)
    );
    I2C_Slave_Full i2c_slave (
        .clk(clk),
        .reset(reset),
        .sda(sda_line),          // Shared SDA line
        .scl(scl_line),          // Shared SCL line
        .data_received(i2c_slave_data),
        .data_valid(i2c_slave_valid)
    );

    // === Data Memory (Block2)
    data_mem dmem (
        .clk(clk),
        .MW(MemWrite),
        .A(addr_out1),
        .WD(write_data_out1),               // ? Correctly use write_data_out2
        .RD(read_data)
    );

    // === Write-back MUX
    assign result =
        (ResultSrc == 2'b00) ? alu_result :
        (ResultSrc == 2'b01) ? read_data :
        (ResultSrc == 2'b10) ? pcplus4 :
        32'b0;

    // === PC Calculations
    assign pcplus4  = pc + 32'd4;
    assign pctarget = pc + imm;
    assign pcnext   = (exec_enable) ? ((PCSrc) ? pctarget : pcplus4) : pc;

endmodule

