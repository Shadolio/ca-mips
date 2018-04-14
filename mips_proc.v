module mips_proc ();

	// CLK and tracker for number of cycles elapsed
	reg clk;
	reg [15:0] cycleNo;
	reg initializing;

	// Special wires for initialization and reading
	wire [31:0] initInstrAddr;

	////////////////////////////////////////////////////////////////
	//////////////// WIRES BY COMPONENT (PORTS)
	////////////////////////////////////////////////////////////////

	// PC
	wire [31:0] pcValue, pcNext;
	reg pcWrite;
	reg pcReset;

	// Instruction Memory
	wire [31:0] instruction, instrAddr;
	reg [31:0] instrIn;
	reg instrWrite, instrRead;

	// Register File
	wire [31:0] regData1, regData2, writeData;
	wire [4:0] readReg1, readReg2, writeReg;
	wire regWrite;

	// ALU
	wire [31:0] aluResult, aluOprd1, aluOprd2;
	wire aluZero;
	wire [3:0] aluOp;

	// Data Memory
	wire [31:0] memDataOut, memAddr, memDataIn;
	wire memWrite, memRead, loadFullWord, loadSigned;

	// Other control signals (intermediate signals and datapath MUX signals)
	wire branch, aluSrc, regDst, memToReg;

	////////////////////////////////////////////////////////////////
	//////////////// PIPELINING/STAGING WIRES
	////////////////////////////////////////////////////////////////

	// PC
	wire [31:0] pcPlus4_F, pcPlus4_D, pcPlus4_E;
	wire [31:0] pcOffsetNextInst_E;

	// Instruction Decode
	wire [31:0] instruction_D;
	wire [15:0] instrImm;
	wire [5:0] instrOpCode, instrFunct;
	wire [4:0] instrRs, instrRt, instrRd, instrShamt;
	wire [4:0] instrRt_E, instrRd_E;
	wire [31:0] imm32_D, shamt32_D;
	wire [31:0] imm32_E, shamt32_E;

	// Register file
	wire [31:0] regData1_E;
	wire [31:0] regData2_E, regData2_M;
	wire [4:0] writeReg_E, writeReg_M;
	wire regWrite_D, regWrite_E, regWrite_M;

	////////////////////////////////////////////////////////////////
	//////////////// WIRES BY STAGE (Wires, links and MUX's)
	////////////////////////////////////////////////////////////////

	// Instruction Fetch

	assign instrAddr = (initializing == 0) ? pcValue : (initializing == 1) ? initInstrAddr : 32'dx;

	assign pcPlus4_F = pcValue + 4;
	assign pcOffsetNextInst_E = pcPlus4_E + (imm32_E << 2);
	assign pcNext = (branch & aluZero) ? pcOffsetNextInst_E : pcPlus4_F;

	// Instruction Decode

	// Divide 32-bit instruction into fields/parameters
	assign instrOpCode = instruction_D[31:26];

	assign instrRs = instruction_D[25:21];
	assign instrRt = instruction_D[20:16];
	assign instrRd = instruction_D[15:11];
	assign instrFunct = instruction_D[5:0];

	assign instrShamt = instruction_D[10:6];
	assign shamt32_D = { 27'd0, instrShamt };

	assign instrImm = instruction_D[15:0];

	SignExtender offsetSignExtender (imm32_D, instrImm, 1'b0);

	// Register file
	assign readReg1 = instrRs;
	assign readReg2 = instrRt;

	// Execute
	assign aluOprd1 = regData1_E;
	assign aluOprd2 = (aluSrc == 0) ? regData2_E : (aluSrc == 1) ? imm32_E : 32'dx;
		// TODO: When SRL or SLL (ALU shift operation,) operand 2 should be 'shamt'
	assign writeReg_E = (regDst == 0) ? instrRt_E : (regDst == 1) ? instrRd_E : 5'dx;

	// Write Back
	assign writeData = (memToReg == 1) ? memDataOut : (memToReg == 0) ? aluResult : 32'dx;

	// MAIN COMPONENTS
	register_32	PC (pcValue, pcNext, pcWrite, pcReset, clk);
	ram		instr_mem (instruction, instrIn, instrAddr, instrWrite, instrRead, 1'b1, 1'bx, clk);
	RegisterFile	reg_file (regData1, regData2, readReg1, readReg2, writeReg, writeData, regWrite, clk);
	ALU		alu (aluZero, aluResult, aluOprd1, aluOprd2, aluOp);
	ram		data_mem (memDataOut, regData2, aluResult, memWrite, memRead, loadFullWord, loadSigned, clk);

	// CONTROL UNIT
	ALU_Controller	aluControl (aluOp, instrOpCode, instrFunct);
	control_unit	CU (branch, aluSrc, regDst, memToReg, regWrite,
				memWrite, memRead, loadFullWord, loadSigned,
				instrOpCode);

	// [ ADD HERE: Pipeline registers ]

	// CONNECT STAGES (REPLACE PIPELINE REGISTERS)

	// PC
	assign pcPlus4_D = pcPlus4_F;
	assign pcPlus4_E = pcPlus4_D;

	// Instruction Decode
	assign instruction_D = instruction;

	assign instrRt_E = instrRt;
	assign instrRd_E = instrRd;

	assign imm32_E = imm32_D;
	assign shamt32_E = shamt32_D;

	// Register file
	assign regData1_E = regData1;

	assign regData2_E = regData2;
	assign regData2_M = regData2_E;

	assign writeReg_M = writeReg_E;
	assign writeReg = writeReg_M;

	// Program initialising and tracking
	// HERE -- THESE ARE CHANGED TOGETHER WITH THE TEST PROGRAM SPECIFIED IN initial BLOCK BELOW "Main()".
	// -----------------------------------
	parameter programLength = 3'd2;	// 1. NUMBER OF INSTRUCTIONS OF TEST PROGRAM TO LOAD
	reg [2:0] instrI;		// 2. NUMBER OF BITS MUST BE ENOUGH TO REPRESENT paramLength
	reg [31:0] program [7:0];	// 3. SHOULD BE ADDRESS COMPATIBLE WITH instrI.
	// -----------------------------------

	assign initInstrAddr = instrI * 4;

	// Main() method
	initial begin

		$display("Welcome to MIPS processor!");
		$display("MIPS processor simulation initializing...");
		initializing <= 1;

		// HERE IS THE TEST PROGRAM TO LOAD
		// Put program instructions in a temp array, to be loaded to Instruction Memory by a loop.
		program[0] <= 32'h20100002; // addi $s0, $0, 2
		program[1] <= 32'h22100003; // addi $s0, $s0, 3
		// ------------------------------------------------------
		// REMEMBER: IF YOU CHANGE THE NUMBER OF INSTRUCTIONS IN THE PROGRAM, CHANGE THE PARAMETERS ABOVE!! (instrI, programLength, program)

		instrWrite <= 1;
		instrRead <= 0;
		pcReset <= 1; // Do this here to gain advantage of the waiting time in the loop
		#5; // The wait is necessary to recognise the signls set above.

		// Load the program to the instruction memory
		for(instrI = 0; instrI < programLength; instrI = instrI + 1) begin

			instrIn <= program[instrI];
			#5 clk <= 1;

			$display("Instruction %d loaded: %h", instrI, instrIn);
			#5 clk <= 0;
		end

		// Reset clk and cycleNo variables
		cycleNo <= 0;		// Initialize cycleNo, a tracking variable
		clk <= 0;		// Make sure the CLK is 0 (if didn't enter the loop, it'd be StX)
		instrWrite <= 0;	// We already loaded the program, nothing will be loaded here again.
		instrRead <= 1;		// Now, allow control unit and rest of data path to execute.
		pcReset <= 0;		// We just set PC to 0 and now we allow it to change.
		pcWrite <= 1;		// Allow pcNext to be written to PC at next clock edge.
		initializing <= 0;	// Now, we are done initializing the processor.

		$display("MIPS processor simulation starting...");

		$monitor("Cycle %d -- PC: %d, Instruction: %h", cycleNo, pcValue, instruction);

		// START CLOCK GENERATOR -- TODO: Stop when program ends or something like that
		forever #5 clk <= ~clk;

		// TODO: At the end, display the values of the whole register file and Data Memory

		/*
		One way for the register file:
			Monitor the wire of ReadData1 or ReadData2.
			Re-initialize the Instruction Memory with 32 instructions of:
				"add $0, $0, {$0-$31}".
			(This will cause the value of the RT register to be readable at ReadData2,
				so we can read it.)
		Another way:
			Simply, do the same but read two registers in one instructions.
			Example: add $0, $0, $1 .. add $0, $2, $3 .. add $0, $4, $5 ...
				This will get one register at ReadData1 and another on ReadData2.
				Despite the ALU adding them and trying to put them in $0,
					we achieved the target of showing their values on the wires.
		[SHADI RECOMMENDS] Third way:
			Instead of achieving this by putting instructions in the Instruction Memory,
				we can multiplex input to the register file,
				to give it our own address instead of addresses from the datapath.
				(Similar to what we did when initializing Instruction Memory.)

		-------------
		The advantage of the first two ways are:
			1) Using existing infrastructure.
			2) We initialized the Instruction Memory before, so we can apply same method.
			3) We avoid complexity of more multiplexing and simulating the entire datapath.
		The advantage of the third way:
			1) We have full control over the register file at that time.
			2) We can easily change addresses (one or two) and observe the new value immediately.
		*/

		/*
		Same ideas for printing contents of Data Memory,
		but with favour of third method so
			we don't add 255*2 instructions (set base address in a register then LW to $0),
			and we don't wait for the whole cycle to read the memory.
		*/

	end

	always @(posedge clk)
		cycleNo = cycleNo + 1;

endmodule
