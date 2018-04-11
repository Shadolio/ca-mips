module control_unit (
			beq, aluSrc, regDst, memToReg,
			regWrite, memWrite, memRead, loadFullWord, loadSigned,
			instrOpCode);

	input [5:0] instrOpCode;
	output beq, aluSrc, regDst, memToReg;
	output regWrite, memWrite, memRead, loadFullWord, loadSigned;

	assign beq = (instrOpCode == 6'h4); // BEQ instruction opcode

	// I-type instructions (except BEQ): 1, otherwise (R-type and BEQ) : 0
	assign aluSrc = (instrOpCode == 6'h23 | instrOpCode == 6'h2B		// LW, SW,
			| instrOpCode == 6'h21 | instrOpCode == 6'h25		// LH, LHU
			| instrOpCode == 6'h8);					// ADDI

	assign regDst = ~aluSrc;

	assign regWrite = (instrOpCode != 6'h2B & instrOpCode != 6'h4); // all instructions except SW and BEQ
	assign memWrite = (instrOpCode == 6'h2B); // SW instruciton opcode

	// LOAD instruction opcode (LW / LH / LHU)
	assign memRead = (instrOpCode == 6'h23 | instrOpCode == 6'h21 | instrOpCode == 6'h25);
	assign loadFullWord = (instrOpCode == 6'h23);
	assign loadSigned = (instrOpCode == 6'h23 | instrOpCode == 6'h21);

	assign memToReg = memRead;

endmodule

module control_unit_tb ();

	reg [5:0] instrOpCode;

	wire beq, aluSrc, regDst, memToReg;
	wire regWrite, memWrite, memRead, loadFullWord, loadSigned;

	control_unit CU (
			beq, aluSrc, regDst, memToReg,
			regWrite, memWrite, memRead, loadFullWord, loadSigned,
			instrOpCode);

	initial begin

		instrOpCode <= 6'h21; // LH

		#5;
		$display("beq: %b, regWrite: %b, memToReg: %b, aluSrc: %b", beq, regWrite, memToReg, aluSrc);
		$display("memWrite: %b, memRead: %b, ldFull: %b, ldS: %b", memWrite, memRead, loadFullWord, loadSigned);
	end

endmodule
