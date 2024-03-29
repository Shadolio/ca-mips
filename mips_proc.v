module mips_proc ();

	// CLK and tracker for number of cycles elapsed
	reg clk;
	reg [15:0] cycleNo;
	reg genClock; 	// 0: stop simulation, 1: keep simulation running (set to 0 when syscall received)
	reg initializing, ending;

	// Manual address lines for Instruction Memory
	// to be used at the beginning, to load the test program into the memory.
	wire [31:0] initInstrAddr;

	// Manual address lines for Register File and Data Memory
	// to be used at the end of the simulation, to print all their contents.
	reg [4:0] endReadReg1, endReadReg2;
	reg [31:0] endMemAddr;

	// Pipeline registers control
	reg reset_IF_ID, reset_ID_EXE, reset_EXE_MEM, reset_MEM_WB;
	reg write_IF_ID, write_ID_EXE, write_EXE_MEM, write_MEM_WB;

	// syscall handling
	// In our simulation, a syscall instruction is exactly equal to a HALT instruction,
	// or equivelant to write value 10 to $v0 then putting a syscall.
	wire syscall_D, syscall_E, syscall_M, syscall_W;

	////////////////////////////////////////////////////////////////
	//////////////// WIRES BY COMPONENT AND STAGES
	////////////////////////////////////////////////////////////////

	//// FETCH

	// PC
	wire [31:0] pcValue, pcNext;
	wire [31:0] pcPlus4_F, pcPlus4_D, pcPlus4_E;
	wire [31:0] pcOffsetNextInst_E;
	wire pcSrc;
	reg pcWrite;
	reg pcReset;

	// Instruction Memory
	wire [31:0] instrAddr;
	wire [31:0] instruction, instruction_D;
	reg [31:0] instrIn;
	reg instrWrite, instrRead;

	//// DECODE

	wire [5:0] instrOpCode, instrFunct;
	wire [15:0] instrImm;
	wire [4:0] instrRs, instrRs_E;
	wire [4:0] instrRt, instrRt_E;
	wire [4:0] instrRd, instrRd_E;
	wire [4:0] instrShamt;
	wire [31:0] imm32_D, imm32_E;

	// Register File
	wire [31:0] regData1, regData1_E;
	wire [31:0] regData2, regData2_E, regData2_M;
	wire [31:0] writeData;
	wire [4:0] readReg1, readReg2;
	wire [4:0] writeReg_E, writeReg_M, writeReg;
	wire regWrite_D, regWrite_E, regWrite_M, regWrite;

	//// EXECUTE

	// ALU
	wire [31:0] aluOprd1, aluOprd2_FWD, aluOprd2;
	wire [4:0] aluShamt;
	wire [3:0] aluOp_D, aluOp;
	wire [31:0] aluResult, aluResult_M, aluResult_W;
	wire aluZero;

	//// MEMORY

	// Data Memory
	wire [31:0] memAddr, memDataIn;
	wire [31:0] memDataOut, memDataOut_W;
	wire memWrite, memRead, loadFullWord, loadSigned;
	wire memWrite_D, memRead_D, loadFullWord_D, loadSigned_D;
	wire memWrite_E, memRead_E, loadFullWord_E, loadSigned_E;
	wire memWrite_M, memRead_M, loadFullWord_M, loadSigned_M;

	//// WRITE BACK
	//			(No special wires to declare in Write Back)

	//// Other control signals (intermediate signals and datapath MUX signals)
	wire branch_D, aluSrc_D, regDst_D;
	wire branch_E, aluSrc_E, regDst_E;
	wire memToReg_D, memToReg_E, memToReg_M, memToReg_W;
	wire shift_D, shift_E;

	// Forwarding signals
	wire [1:0] fwdA, fwdB;

	////////////////////////////////////////////////////////////////
	//////////////// WIRE CONNECTIONS BY STAGE
	////////////////////////////////////////////////////////////////

	// INSTRUCTION FETCH

	assign pcPlus4_F = pcValue + 4;
	assign pcOffsetNextInst_E = pcPlus4_E + (imm32_E << 2);
	assign pcSrc = branch_E & aluZero;
	assign pcNext = pcSrc ? pcOffsetNextInst_E : pcPlus4_F;

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

	assign syscall_D = (instruction_D == 32'h0000000c);

	SignExtender offsetSignExtender (imm32_D, instrImm, 1'b0);

	// Register file
	assign readReg1 = ending ? endReadReg1 : instrRs;
	assign readReg2 = ending ? endReadReg2 : instrRt;

	// EXECUTE
	assign aluOprd2 = aluSrc_E ? imm32_E : aluOprd2_FWD;

	mux_4_x_32 aluOprd1_fwdMux (aluOprd1, regData1_E, writeData, aluResult_M, 32'dx, regData1_E, fwdA);
	mux_4_x_32 aluOprd2_fwdMux (aluOprd2_FWD, regData2_E, writeData, aluResult_M, 32'dx, regData2_E, fwdB);

	assign writeReg_E = regDst_E ? instrRd_E : instrRt_E;

	// MEMORY
	assign memAddr = ending ? endMemAddr : aluResult_M;
	assign memDataIn = regData2_M;

	assign memRead = ending ? 1'b1 : memRead_M;
	assign memWrite = ending ? 1'b0 : memWrite_M;
	assign loadFullWord = ending ? 1'b0 : loadFullWord_M;
	assign loadSigned = ending ? 1'b0 : loadSigned_M;

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

	// FORWARDING UNIT
	fwd_unit	FU (fwdA, fwdB, instrRs_E, instrRt_E, writeReg_M, writeReg, regWrite_M, regWrite);

	////////////////////////////////////////////////////////////////
	//////////////// Pipeline registers
	////////////////////////////////////////////////////////////////

	// IF/ID
	IF_ID_ppreg IF_ID (instruction_D, pcPlus4_D, instruction, pcPlus4_F, write_IF_ID, reset_IF_ID, clk);

	// ID/EXE
	ID_EXE_ppreg ID_EXE (
		pcPlus4_E, pcPlus4_D, syscall_E, syscall_D,
		instrRs_E, instrRs, instrRt_E, instrRt, instrRd_E, instrRd,
		imm32_E, imm32_D, aluShamt, instrShamt,
		regData1_E, regData1, regData2_E, regData2,
		aluOp, aluOp_D, aluSrc_E, aluSrc_D, shift_E, shift_D,
		regDst_E, regDst_D, regWrite_E, regWrite_D, branch_E, branch_D, memToReg_E, memToReg_D,
		memWrite_E, memWrite_D, memRead_E, memRead_D,
		loadFullWord_E, loadFullWord_D, loadSigned_E, loadSigned_D,
		write_ID_EXE, reset_ID_EXE, clk);

	// EXE/MEM
	EXE_MEM_ppreg EXE_MEM (
		syscall_M, syscall_E,
		regData2_M, regData2_E, aluResult_M, aluResult,
		writeReg_M, writeReg_E,
		regWrite_M, regWrite_E, memToReg_M, memToReg_E,
		memWrite_M, memWrite_E, memRead_M, memRead_E,
		loadFullWord_M, loadFullWord_E, loadSigned_M, loadSigned_E,
		write_EXE_MEM, reset_EXE_MEM, clk);

	// MEM/WB
	MEM_WB_ppreg MEM_WB (
		syscall_W, syscall_M,
		memDataOut_W, memDataOut, aluResult_W, aluResult_M,
		writeReg, writeReg_M,
		regWrite, regWrite_M, memToReg_W, memToReg_M,
		write_MEM_WB, reset_MEM_WB, clk);


	// Program initialising and tracking
	// HERE -- CHANGE IFF (MEMORY SIZE) OR (TEST PROGRAM SPECIFIED IN initial BLOCK BELOW "Main()") CHANGE.
	// -----------------------------------
	parameter programLength = 5'd08;		// NUMBER OF INSTRUCTIONS OF TEST PROGRAM TO LOAD
	reg [31:0] program [programLength - 1 : 0];
	reg [4:0] instrI;

	assign initInstrAddr = instrI * 4;
	// -----------------------------------

	// Main() method
	initial begin

		$display("Welcome to MIPS processor!");
		$display("MIPS processor simulation initializing...");
		initializing <= 1;
		ending <= 0;

		// Set all Reset signals for pipeline registers, and their write signals to zero
		{ reset_IF_ID, reset_ID_EXE, reset_EXE_MEM, reset_MEM_WB } <= 4'b1111;
		{ write_IF_ID, write_ID_EXE, write_EXE_MEM, write_MEM_WB } <= 4'b0000;

		// HERE IS THE TEST PROGRAM TO LOAD
		// Put program instructions in a temp array, to be loaded to Instruction Memory by a loop.

		program[0] <= 32'h20110005; // addi $17, $0, 5
		program[1] <= 32'h20100002; // addi $16, $0, 2
		program[2] <= 32'h2012fffd; // addi $18, $0, -3
		program[3] <= 32'hac000005; // sw $0, 5($0)
		program[4] <= 32'h00009820; // add $19, $0, $0
		program[5] <= 32'h00119842; // srl $19, $17, 1
		program[6] <= 32'h02304822; // sub $9, $17, $16
		program[7] <= 32'h0000000c; // syscall #end program

		// testProg_beq_noFwd (now with FWD)
		/*program[0] <= 32'h20100005;	// addi $16, $0, 5
		program[1] <= 32'h12000006;	// beq $16, $0, 0x6
		program[2] <= 32'h00000000;	// nop
		program[3] <= 32'h00000000;	// nop
		program[4] <= 32'h2210ffff;	// addi $16, $16, -1
		program[5] <= 32'h1000fffb;	// beq $0, $0, 0xfffb
		program[6] <= 32'h00000000;	// nop
		program[7] <= 32'h00000000;	// nop
		program[8] <= 32'h2002000a;	// addi $2, $0, 10
		program[9] <= 32'h0000000c;	// syscall
		*/

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
		genClock <= 1;		// Activate the clock of the simulation
		instrWrite <= 0;	// We already loaded the program, nothing will be loaded here again.
		instrRead <= 1;		// Now, allow control unit and rest of data path to execute.
		pcReset <= 0;		// We just set PC to 0 and now we allow it to change.
		pcWrite <= 1;		// Allow pcNext to be written to PC at next clock edge.
		initializing <= 0;	// Now, we are done initializing the processor.

		// Now, we want to allow the pipeline registers to keep getting updated normally.
		{ reset_IF_ID, reset_ID_EXE, reset_EXE_MEM, reset_MEM_WB } <= 4'b0000;
		{ write_IF_ID, write_ID_EXE, write_EXE_MEM, write_MEM_WB } <= 4'b1111;

		#5 $display("MIPS processor simulation starting.");

		// START CLOCK GENERATOR
		while(genClock) #5 clk <= ~clk;

		$display("Simulation complete.");
		ending <= 1;

		// Display contents of register file at the end of the simulation
		endReadReg1 <= 5'd0;
		endReadReg2 <= 5'd1;
		$display("Register file contents:");

		repeat(16) begin

			#5 $display("Reg %d: %d .. Reg %d: %d", endReadReg1, regData1, endReadReg2, regData2);

			endReadReg1 <= endReadReg1 + 2;
			endReadReg2 <= endReadReg2 + 2;
		end

		// Display contents of Data Memory at the end of the simulation
		endMemAddr <= 32'd0;
		$display("\nData Memory contents:");

		repeat(64) begin

			#5 $display("Mem[%d]: %b", endMemAddr, memDataOut[7:0]);

			endMemAddr <= endMemAddr + 1;
		end

	end

	always @(posedge clk)
		cycleNo = cycleNo + 1;

	// When a syscall reaches WriteBack stage, then all preceding instructions have passed,
	// stop generating lock and exit the generation loop to the printing code.
	always @(posedge syscall_W)
		genClock <= 1'b0;

	always @(cycleNo) begin

		$display("\n-------- -------- -------- -------- --------");
		$display("Cycle %d", cycleNo);
		//$display("Cycle %d -- PC: %d, Instruction: %h", cycleNo, pcValue, instruction);

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
		$display("\tfwdA: %b, fwdB: %b", fwdA, fwdB);
		$display("\toprd1: %d, oprd2: %d, shamt: %d", aluOprd1, aluOprd2, aluShamt);
		$display("\taluSrc: %b, aluOp: %d", aluSrc_E, aluOp);
		$display("\tresult: %d, zero: %b", aluResult, aluZero);
		$display("Rs: %d, Rt: %d, Rd: %d, writeReg: %d, regDst: %b", instrRs_E, instrRt_E, instrRd_E, writeReg_E, regDst_E);
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

		$display("======== ======== ======== ======== ========\n");
	end

endmodule
