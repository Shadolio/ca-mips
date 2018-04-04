module mips_proc ();

	// CLK and tracker for number of cycles elapsed
	reg clk;
	reg [15:0] cycleNo;

	// Control unit wires (output signals)
	reg branch, regDst, aluSrc;

	// Instruction Memory wires
	wire [31:0] instruction;
	reg [31:0] instrIn;
	reg instrWrite;

	// Instruction Decode: Take certain parameters/fields from the 32-bit instruction
	wire [5:0] instrOpCode, instrFunct;
	wire [4:0] instrRs, instrRt, instrRd, instrShamt;
	wire [15:0] instrImm;
	wire [31:0] immOffset32bits;

	assign instrOpCode = instruction[31:26];

	assign instrRs = instruction[25:21];
	assign instrRt = instruction[20:16];
	assign instrRd = instruction[15:11];
	assign instrShamt = instruction[10:6];
	assign instrFunct = instruction[5:0];

	assign instrImm = instruction[15:0];

	SignExtender offsetSignExtender (immOffset32bits, instrImm, 0);

	// Register File wires
	wire [31:0] regData1, regData2, writeData;
	wire [4:0] readReg1, readReg2, writeReg;
	reg regWrite;

	assign readReg1 = instrRs;
	assign readReg2 = instrRt;
	assign writeReg = (regDst == 0) ? instrRt : (regDst == 1) ? instrRd : 5'dx;

	// ALU wires
	wire [31:0] aluResult, aluOprd2;
	wire aluZero;
	wire [3:0] aluOp;

	assign aluOprd2 = (aluSrc == 0) ? regData2 : (aluSrc == 1) ? immOffset32bits : 32'dx;

	// PC wires
	wire [31:0] pcValue, pcNext, pcPlus4, pcOffsetNextInst;
	reg pcWrite;
	reg pcReset;

	assign pcPlus4 = pcValue + 4;
	assign pcNext = (branch & aluZero) ? pcOffsetNextInst : pcPlus4;
	assign pcOffsetNextInst = pcNext + (immOffset32bits << 2);

	// MAIN COMPONENTS
	program_counter	PC (pcValue, pcWrite, pcNext, pcReset, clk);
	ram		instr_mem (instruction, instrIn, pcValue, instrWrite, 1'b1, 1'bx, clk);
	RegisterFile	reg_file (regData1, regData2, readReg1, readReg2, writeReg, writeData, regWrite, clk);
	ALU		alu (aluZero, aluResult, regData1, aluOprd2, aluOp);

	// [ ADD HERE: Pipeline registers ]

	// [ ADD HERE: Control Unit ]
	ALU_Controller aluControl (aluOp, instrOpCode, instrFunct);

	// Main() method
	initial begin

		// Initialise clk and cycleNo variables
		cycleNo <= 0;
		clk <= 0;
		pcReset <= 1;

		branch <= 0;
		regDst <= 1;
		aluSrc <= 0;
		regWrite <= 1;

		// TODO: Load instruction(s) to memory to be executed.
		instrIn <= 32'h02128020;
		instrWrite <= 1;

		$display("MIPS processor starting...");
		$display("Welcome to MIPS processor!");

		// START CLOCK GENERATOR
		forever #5 clk <= ~clk;

	end

	initial $monitor("Cycle %d", cycleNo);

	initial $monitor("PC: %d", pcValue);
	initial $monitor("current instruction: %h", instruction);

	always @(posedge clk)
		cycleNo = cycleNo + 1;

endmodule
