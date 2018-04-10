module mips_proc ();

	// CLK and tracker for number of cycles elapsed
	reg clk;
	reg [15:0] cycleNo;
	reg initializing;

	// Control unit wires (output signals)
	reg branch, aluSrc, regDst, memToReg;
	reg regWrite;
	reg memWrite, memRead, loadFullWord, loadSigned;

	// [ ADD HERE: Pipelining wires ]

	// Instruction Memory wires
	wire [31:0] instruction, instrAddr;
	reg [31:0] instrIn;
	reg instrWrite, instrRead;

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
	ram		instr_mem (instruction, instrIn, instrAddr, instrWrite, instrRead, 1'b1, 1'bx, clk);
	RegisterFile	reg_file (regData1, regData2, readReg1, readReg2, writeReg, writeData, regWrite, clk);
	ALU		alu (aluZero, aluResult, regData1, aluOprd2, aluOp);
	ram		data_mem (memData, regData2, aluResult, memWrite, memRead, loadFullWord, loadSigned, clk);

	// [ ADD HERE: Pipeline registers ]

	// [ ADD HERE: Control Unit ]
	ALU_Controller aluControl (aluOp, instrOpCode, instrFunct);

	// Program initialising and tracking
	// HERE -- THESE ARE CHANGED TOGETHER WITH THE TEST PROGRAM SPECIFIED IN initial BLOCK BELOW "Main()".
	// -----------------------------------
	parameter programLength = 3'd2;	// 1. NUMBER OF INSTRUCTIONS OF TEST PROGRAM TO LOAD
	reg [2:0] instrI;		// 2. NUMBER OF BITS MUST BE ENOUGH TO REPRESENT paramLength
	reg [31:0] program [8:0];	// 3. SHOULD BE ADDRESS COMPATIBLE WITH instrI.
	// -----------------------------------

	assign instrAddr = (initializing == 0) ? pcValue : (initializing == 1) ? (instrI * 4) : 32'dx;

	// Main() method
	initial begin

		$display("Welcome to MIPS processor!");
		$display("MIPS processor simulation initializing...");
		initializing <= 1;

		// HERE IS THE TEST PROGRAM TO LOAD
		// Put program instructions in a temp array, to be loaded to Instruction Memory by a loop.
		program[0] <= 32'h20100002; // add $s0, $0, $0
		program[1] <= 32'h22100003; // add $s0, $s0, $s0
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

		// Simulate some control signals (instead of control unit)
		branch <= 0;
		regDst <= 0;
		aluSrc <= 1;
		memRead <= 1;
		memToReg <= 0;
		regWrite <= 1;

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
