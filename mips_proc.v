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
	wire [4:0] aluShamt;

	// Data Memory
	wire [31:0] memDataOut, memAddr, memDataIn;
	wire memWrite, memRead, loadFullWord, loadSigned;

	// Other control signals (intermediate signals and datapath MUX signals)
	wire branch_D, aluSrc_D, regDst_D, memToReg_D;

	////////////////////////////////////////////////////////////////
	//////////////// PIPELINING/STAGING WIRES
	////////////////////////////////////////////////////////////////

	// PC
	wire [31:0] pcPlus4_F, pcPlus4_D, pcPlus4_E;
	wire [31:0] pcOffsetNextInst_E;
	wire pcSrc;

	// Instruction Decode
	wire [31:0] instruction_D;
	wire [15:0] instrImm;
	wire [5:0] instrOpCode, instrFunct;
	wire [4:0] instrRs, instrRt, instrRd, instrShamt;
	wire [4:0] instrRt_E, instrRd_E;
	wire [31:0] imm32_D, imm32_E;

	// Register file
	wire [31:0] regData1_E;
	wire [31:0] regData2_E, regData2_M;
	wire [4:0] writeReg_E, writeReg_M;
	wire regWrite_D, regWrite_E, regWrite_M;

	// ALU
	wire [31:0] aluResult_M, aluResult_W;
	wire [3:0] aluOp_D;
	wire shift_D, shift_E;

	// Data Memory
	wire [31:0] memDataOut_W;
	wire memWrite_D, memRead_D, loadFullWord_D, loadSigned_D;
	wire memWrite_E, memRead_E, loadFullWord_E, loadSigned_E;

	// Other control signals (intermediate signals and datapath MUX signals)
	wire branch_E, aluSrc_E, regDst_E;
	wire memToReg_E, memToReg_M, memToReg_W;

	////////////////////////////////////////////////////////////////
	//////////////// WIRES BY STAGE (Wires, links and MUX's)
	////////////////////////////////////////////////////////////////

	// INSTRUCTION FETCH

	assign pcPlus4_F = pcValue + 4;
	assign pcOffsetNextInst_E = pcPlus4_E + (imm32_E << 2);
	//assign pcNext = pcSrc ? pcOffsetNextInst_E : (pcSrc == 0 | pcSrc == 1'bx) ? pcPlus4_F : 32'd0;
	assign pcSrc = branch_E & aluZero;

	mux_01x_32 pcNext_Mux (pcNext, pcPlus4_F, pcOffsetNextInst_E, pcPlus4_F, pcSrc);

	assign instrAddr = (initializing == 0) ? pcValue : (initializing == 1) ? initInstrAddr : 32'dx;

	// INSTRUCTION DECODE

	// Divide 32-bit instruction into fields/parameters
	assign instrOpCode = instruction_D[31:26];

	assign instrRs = instruction_D[25:21];
	assign instrRt = instruction_D[20:16];
	assign instrRd = instruction_D[15:11];
	assign instrFunct = instruction_D[5:0];

	assign instrShamt = instruction_D[10:6];

	assign instrImm = instruction_D[15:0];

	SignExtender offsetSignExtender (imm32_D, instrImm, 1'b0);

	// Register file
	assign readReg1 = instrRs;
	assign readReg2 = instrRt;

	// EXECUTE
	assign aluOprd1 = regData1_E;
	assign aluOprd2 = aluSrc_E ? imm32_E : regData2_E;

	assign writeReg_E = regDst_E ? instrRd_E : instrRt_E;

	// MEMORY
	assign memAddr = aluResult_M;
	assign memDataIn = regData2_M;

	// WRITE BACK
	assign writeData = memToReg_W ? memDataOut_W : aluResult_W;

	////////////////////////////////////////////////////////////////
	//////////////// Components
	////////////////////////////////////////////////////////////////

	// MAIN COMPONENTS
	register_32	PC (pcValue, pcNext, pcWrite, pcReset, clk);
	ram		instr_mem (instruction, instrIn, instrAddr, instrWrite, instrRead, 1'b1, 1'bx, clk);
	RegisterFile	reg_file (regData1, regData2, readReg1, readReg2, writeReg, writeData, regWrite, clk);
	ALU		alu (aluZero, aluResult, aluOprd1, aluOprd2, aluShamt, aluOp);
	ram		data_mem (memDataOut, memDataIn, memAddr, memWrite, memRead, loadFullWord, loadSigned, clk);

	// CONTROL UNIT
	ALU_Controller	aluControl (aluOp_D, instrOpCode, instrFunct);
	control_unit	CU (branch_D, shift_D, aluSrc_D, regDst_D, memToReg_D, regWrite_D,
				memWrite_D, memRead_D, loadFullWord_D, loadSigned_D,
				instrOpCode, instrFunct);

	////////////////////////////////////////////////////////////////
	//////////////// Pipelining
	////////////////////////////////////////////////////////////////

	// IF/ID
	IF_ID_ppreg IF_ID (instruction_D, pcPlus4_D, instruction, pcPlus4_F, 1'b1, 1'b0, clk);

	// ID/EXE
	ID_EXE_ppreg ID_EXE (
		pcPlus4_E, pcPlus4_D, instrRt_E, instrRt, instrRd_E, instrRd,
		imm32_E, imm32_D, aluShamt, instrShamt,
		regData1_E, regData1, regData2_E, regData2,
		aluOp, aluOp_D, aluSrc_E, aluSrc_D, shift_E, shift_D,
		regDst_E, regDst_D, regWrite_E, regWrite_D, branch_E, branch_D, memToReg_E, memToReg_D,
		memWrite_E, memWrite_D, memRead_E, memRead_D,
		loadFullWord_E, loadFullWord_D, loadSigned_E, loadSigned_D,
		1'b1, 1'b0, clk);

	// EXE/MEM
	EXE_MEM_ppreg EXE_MEM (
		regData2_M, regData2_E, aluResult_M, aluResult,
		writeReg_M, writeReg_E,
		regWrite_M, regWrite_E, memToReg_M, memToReg_E,
		memWrite, memWrite_E, memRead, memRead_E,
		loadFullWord, loadFullWord_E, loadSigned, loadSigned_E,
		1'b1, 1'b0, clk);

	// MEM/WB
	MEM_WB_ppreg MEM_WB (
		memDataOut_W, memDataOut, aluResult_W, aluResult_M,
		writeReg, writeReg_M,
		regWrite, regWrite_M, memToReg_W, memToReg_M,
		1'b1, 1'b0, clk);

	// Program initialising and tracking
	// HERE -- THESE ARE CHANGED TOGETHER WITH THE TEST PROGRAM SPECIFIED IN initial BLOCK BELOW "Main()".
	// -----------------------------------
	parameter programLength = 5'd7;			// NUMBER OF INSTRUCTIONS OF TEST PROGRAM TO LOAD
	reg [4:0] instrI;
	reg [31:0] program [programLength - 1 : 0];

	assign initInstrAddr = instrI * 4;
	// -----------------------------------

	// Main() method
	initial begin

		$display("Welcome to MIPS processor!");
		$display("MIPS processor simulation initializing...");
		initializing <= 1;

		// HERE IS THE TEST PROGRAM TO LOAD
		// Put program instructions in a temp array, to be loaded to Instruction Memory by a loop.

		program[0] <= 32'h20110005; // addi $17, $0, 5
		program[1] <= 32'h20100002; // addi $16, $0, 2
		program[2] <= 32'h2012fffd; // addi $18, $0, -3
		program[3] <= 32'hac000005; // sw $0, 5($0)
		program[4] <= 32'h00009820; // add $19, $0, $0
		program[5] <= 32'h00119842; // srl $19, $17, 1
		program[6] <= 32'h02304822; // sub $9, $17, $16

		// ------------------------------------------------------
		// REMEMBER TO UPDATE THE PARAMETER ABOVE WITH THE NUMBER OF INSTRUCTIONS IN THE PROGRAM

		instrWrite <= 1;
		instrRead <= 0;
		pcReset <= 1; // Do this here to gain advantage of the waiting time in the loop
		#5; // The wait is necessary to recognise the signls set above.

		// Load the program to the instruction memory
		for(instrI = 5'd0; instrI < programLength; instrI = instrI + 1) begin

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

		// START CLOCK GENERATOR -- TODO: Stop when program ends or something like that
		repeat(24) #5 clk <= ~clk;

		$display("simulation complete");

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

	always @(cycleNo) begin

		$display("-------- -------- -------- -------- --------");
		$display("Cycle %d", cycleNo);
		//$monitor("Cycle %d -- PC: %d, Instruction: %h", cycleNo, pcValue, instruction);

		$display("======== -------- -------- -------- --------");
		$display("FETCH");
		$display("PC: %d, Instruction: %h", pcValue, instruction);
		$display("PC+4: %d, PCSrc: %b, PCnext: %d", pcPlus4_F, pcSrc, pcNext);

		$display("-------- ======== -------- -------- --------");
		$display("DECODE");
		$display("Instruction: %b (%h), PC+4: %d", instruction_D, instruction_D, pcPlus4_D);
		$display("OpCode: %h, Funct: %h", instrOpCode, instrFunct);
		$display("Rs: %b, Rt: %b, Rd: %b, shamt: %b", instrRs, instrRt, instrRd, instrShamt);
		$display("offset/immediate: %b", instrImm);
		$display("RegFile -- addr1: %b, data1: %d, addr2: %b, data2: %d",
			readReg1, regData1, readReg2, regData2);
		$display("Control unit --");
		$display("\tbranch: %b, aluSrc: %b, aluOp: %d, regDst: %b", branch_D, aluSrc_D, aluOp_D, regDst_D);
		$display("\tmemRead: %b, memWrite: %b, fullWord: %b, signed: %b", memRead_D, memWrite_D, loadFullWord_D, loadSigned_D);
		$display("\tmemToReg: %b, regWrite: %b", memToReg_D, regWrite_D);

		$display("-------- -------- ======== -------- --------");
		$display("EXECUTE");
		$display("PC+4: %d, branch: %b", pcPlus4_E, branch_E);
		$display("Regs - data1: %d, data2: %d", regData1_E, regData2_E);
		$display("Immediate (32 bits): %b", imm32_E);
		$display(".. shift left by 2: %b", imm32_E << 2);
		$display(".. add to PC+4: DEC %d", pcOffsetNextInst_E);
		$display("ALU --");
		$display("\toprd1: %d, oprd2: %d, shamt: %d", aluOprd1, aluOprd2, aluShamt);
		$display("\taluSrc: %b, aluOp: %d", aluSrc_E, aluOp);
		$display("\tresult: %d, zero: %b", aluResult, aluZero);
		$display("Rt: %d, Rd: %d, writeReg: %d, regDst: %b", instrRt_E, instrRd_E, writeReg_E, regDst_E);
		$display("Control unit --");
		$display("\tmemRead: %b, memWrite: %b, fullWord: %b, signed: %b", memRead_E, memWrite_E, loadFullWord_E, loadSigned_E);
		$display("\tmemToReg: %b, regWrite: %b", memToReg_E, regWrite_E);

		$display("-------- -------- -------- ======== --------");
		$display("MEMORY");
		$display("aluResult: %d, memAddress: %h", aluResult_M, memAddr);
		$display("regData2: %d -> memDataIn: %d", regData2_M, memDataIn);
		$display("memDataOut: %d", memDataOut);
		$display("memRead: %b, memWrite: %b, fullWord: %b, signed: %b", memRead, memWrite, loadFullWord, loadSigned);
		$display("Control unit -- memToReg: %b, regWrite: %b", memToReg_M, regWrite_M);
		$display("writeReg: %d", writeReg_M);

		$display("-------- -------- -------- -------- ========");
		$display("WRITE BACK");
		$display("memToReg: %b, memData: %d, alu: %d", memToReg_W, memDataOut_W, aluResult_W);
		$display("writeReg: %d, regWrite: %b, data: %d", writeReg, regWrite, writeData);

		$display("======== ======== ======== ======== ========");
	end

endmodule
