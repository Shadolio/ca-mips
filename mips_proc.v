module mips_proc ();

	// CLK and tracker for number of cycles elapsed
	reg clk;
	reg [15:0] cycleNo;
	reg initializing;

	// Control unit wires (output signals)
	reg branch, regDst, regWrite, aluSrc, memToReg;
	reg memWrite, memRead, loadFullWord, loadSigned;

	// Instruction Memory wires
	wire [31:0] instruction, instrAddr;
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

	SignExtender offsetSignExtender (immOffset32bits, instrImm, 1'b0);

	// Register File wires
	wire [31:0] regData1, regData2, writeData;
	wire [4:0] readReg1, readReg2, writeReg;

	assign readReg1 = instrRs;
	assign readReg2 = instrRt;
	assign writeReg = (regDst == 0) ? instrRt : (regDst == 1) ? instrRd : 5'dx;

	// ALU wires
	wire [31:0] aluResult, aluOprd2;
	wire aluZero;
	wire [3:0] aluOp;

	assign aluOprd2 = (aluSrc == 0) ? regData2 : (aluSrc == 1) ? immOffset32bits : 32'dx;

	// Data Memory wires
	wire [31:0] memData;

	// Write Back: Assign writeData of registerFile to either Data Memory or ALU directly
	assign writeData = (memToReg == 1) ? memData : (memToReg == 0) ? aluResult : 32'dx;

	// PC wires
	wire [31:0] pcValue, pcNext, pcPlus4, pcOffsetNextInst;
	reg pcWrite;
	reg pcReset;

	assign pcPlus4 = pcValue + 4;
	assign pcNext = (branch & aluZero) ? pcOffsetNextInst : pcPlus4;
	assign pcOffsetNextInst = pcNext + (immOffset32bits << 2);

	// MAIN COMPONENTS
	program_counter	PC (pcValue, pcWrite, pcNext, pcReset, clk);
	ram		instr_mem (instruction, instrIn, instrAddr, instrWrite, 1'b1, 1'bx, clk);
	RegisterFile	reg_file (regData1, regData2, readReg1, readReg2, writeReg, writeData, regWrite, clk);
	ALU		alu (aluZero, aluResult, regData1, aluOprd2, aluOp);
	ram		data_mem (memData, regData2, aluResult, memWrite, loadFullWord, loadSigned, clk);

	// [ ADD HERE: Pipeline registers ]

	// [ ADD HERE: Control Unit ]
	ALU_Controller aluControl (aluOp, instrOpCode, instrFunct);

	// Program initialising and tracking
	reg [2:0] instrI;
	reg [31:0] program [8:0];
	parameter programLength = 3'd2;

	assign instrAddr = (initializing == 0) ? pcValue : (initializing == 1) ? (instrI * 4) : 32'dx;

	// Main() method
	initial begin

		$display("MIPS processor simulation starting...");
		initializing <= 1;

		// Put program instructions in a temp array, to be loaded to instruction memory by a loop.
		program[0] <= 32'h00008020; // add $s0, $0, $0
		program[1] <= 32'h02108020; // add $s0, $s0, $s0

		instrWrite <= 1;
		pcReset <= 1; // Do this here to gain advantage of the waiting time in the loop
		#5; // This wait is necessary to recognise the instruction write signals

		// Initialise instruction memory with test program
		for(instrI = 0; instrI < programLength; instrI = instrI + 1) begin

			instrIn <= program[instrI];
			#5 clk <= 1;

			$display("Instruction %d loaded: %h", instrI, instrIn);
			#5 clk <= 0;
		end

		// Initialise clk and cycleNo variables
		cycleNo <= 0;
		clk <= 0;
		pcReset <= 0;
		pcWrite <= 1;
		initializing <= 0;

		// Simulate some control signals until control unit is integrated
		branch <= 0;
		regDst <= 1;
		aluSrc <= 0;
		memToReg <= 0;
		regWrite <= 1;

		$display("Welcome to MIPS processor!");

		$monitor("Cycle %d -- PC: %d, Instruction: %h", cycleNo, pcValue, instruction);

		// START CLOCK GENERATOR
		forever #5 clk <= ~clk;

	end

	always @(posedge clk)
		cycleNo = cycleNo + 1;

endmodule
