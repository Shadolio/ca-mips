module ID_EXE_ppreg (
	pcPlus4Out, pcPlus4In,
	instrRtOut, instrRtIn, instrRdOut, instrRdIn,
	imm32Out, imm32In, shamt32Out, shamt32In,
	regData1Out, regData1In, regData2Out, regData2In,
	aluOpOut, aluOpIn, aluSrcOut, aluSrcIn,
	regDstOut, regDstIn, regWriteOut, regWriteIn,
	branchOut, branchIn, memToRegOut, memToRegIn,
	write, reset, clk);
	input write, reset, clk;
	input [31:0] pcPlus4In, imm32In, shamt32In, regData1In, regData2In;
	input [4:0] instrRtIn, instrRdIn;
	input [3:0] aluOpIn;
	input aluSrcIn, regDstIn, regWriteIn, branchIn, memToRegIn;
	output [31:0] pcPlus4Out, imm32Out, shamt32Out, regData1Out, regData2Out;
	output [4:0] instrRtOut, instrRdOut;
	output [3:0] aluOpOut;
	output aluSrcOut, regDstOut, regWriteOut, branchOut, memToRegOut;

	wire [4:0] aluOpIn5, aluOpOut5;

	assign aluOpOut = aluOpOut5[3:0];
	assign aluOpIn5 = { 1'd0, aluOpIn };

	register_32 pcPlus4Reg (pcPlus4Out, pcPlus4In, write, reset, clk);
	register_32 imm32Reg (imm32Out, imm32In, write, reset, clk);
	register_32 shamt32Reg (shamt32Out, shamt32In, write, reset, clk);
	register_32 regData1Reg (regData1Out, regData1In, write, reset, clk);
	register_32 regData2Reg (regData2Out, regData2In, write, reset, clk);

	register_5 instrRtReg (instrRtOut, instrRtIn, write, reset, clk);
	register_5 instrRdReg (instrRdOut, instrRdIn, write, reset, clk);

	register_5 aluOpReg (aluOpOut5, aluOpIn5, write, reset, clk);

	D_FlipFlop aluSrcFF	(aluSrcOut, aluSrcIn, write, reset, clk);
	D_FlipFlop regDstFF	(regDstOut, regDstIn, write, reset, clk);
	D_FlipFlop regWriteFF	(regWriteOut, regWriteIn, write, reset, clk);
	D_FlipFlop branchFF	(branchOut, branchIn, write, reset, clk);
	D_FlipFlop memToRegFF	(memToRegOut, memToRegIn, write, reset, clk);

endmodule

module ID_EXE_ppreg_tb ();
	reg write, reset, clk;
	reg [31:0] pcPlus4In, imm32In, shamt32In, regData1In, regData2In;
	reg [4:0] instrRtIn, instrRdIn;
	reg [3:0] aluOpIn;
	reg aluSrcIn, regDstIn, regWriteIn, branchIn, memToRegIn;
	wire [31:0] pcPlus4Out, imm32Out, shamt32Out, regData1Out, regData2Out;
	wire [4:0] instrRtOut, instrRdOut;
	wire [3:0] aluOpOut;
	wire aluSrcOut, regDstOut, regWriteOut, branchOut, memToRegOut;

	ID_EXE_ppreg testPPreg (
		pcPlus4Out, pcPlus4In,
		instrRtOut, instrRtIn, instrRdOut, instrRdIn,
		imm32Out, imm32In, shamt32Out, shamt32In,
		regData1Out, regData1In, regData2Out, regData2In,
		aluOpOut, aluOpIn, aluSrcOut, aluSrcIn,
		regDstOut, regDstIn, regWriteOut, regWriteIn,
		branchOut, branchIn, memToRegOut, memToRegIn,
		write, reset, clk);

	initial begin

		$monitor("PC in: %h, PC out: %h, Rd in: %h, Rd out: %h, ALU in: %h, ALU out: %h, branch in: %b, branch out: %b", pcPlus4In, pcPlus4Out, instrRdIn, instrRdOut, aluOpIn, aluOpOut, branchIn, branchOut);

		pcPlus4In <= 32'd4;
		instrRdIn <= 5'd5;
		aluOpIn <= 4'd4;
		branchIn <= 1'b0;

		write <= 1;
		#5 clk <= 1;

	end

endmodule
