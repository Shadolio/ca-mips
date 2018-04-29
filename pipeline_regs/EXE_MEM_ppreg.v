module EXE_MEM_ppreg (
	syscallOut, syscallIn,
	regData2Out, regData2In, aluResultOut, aluResultIn,
	writeRegOut, writeRegIn,
	regWriteOut, regWriteIn, memToRegOut, memToRegIn,
	memWriteOut, memWriteIn, memReadOut, memReadIn,
	loadFullWordOut, loadFullWordIn, loadSignedOut, loadSignedIn,
	write, reset, clk);
	input write, reset, clk;
	input [31:0] regData2In, aluResultIn;
	input [4:0] writeRegIn;
	input regWriteIn, memToRegIn;
	input memWriteIn, memReadIn, loadFullWordIn, loadSignedIn;
	input syscallIn;
	output [31:0] regData2Out, aluResultOut;
	output [4:0] writeRegOut;
	output regWriteOut, memToRegOut;
	output memWriteOut, memReadOut, loadFullWordOut, loadSignedOut;
	output syscallOut;

	register_32 regData2Reg (regData2Out, regData2In, write, reset, clk);
	register_32 aluResultReg (aluResultOut, aluResultIn, write, reset, clk);

	register_5 writeRegReg (writeRegOut, writeRegIn, write, reset, clk);

	D_FlipFlop regWriteFF	(regWriteOut, regWriteIn, write, reset, clk);
	D_FlipFlop memToRegFF	(memToRegOut, memToRegIn, write, reset, clk);

	D_FlipFlop memWriteFF	(memWriteOut, memWriteIn, write, reset, clk);
	D_FlipFlop memReadFF	(memReadOut, memReadIn, write, reset, clk);
	D_FlipFlop loadFullWord	(loadFullWordOut, loadFullWordIn, write, reset, clk);
	D_FlipFlop loadSignedFF	(loadSignedOut, loadSignedIn, write, reset, clk);

	D_FlipFlop syscallFF	(syscallOut, syscallIn, write, reset, clk);

endmodule

module EXE_MEM_ppreg_tb ();
	reg write, reset, clk;
	reg [31:0] regData2In, aluResultIn;
	reg [4:0] writeRegIn;
	reg regWriteIn, memToRegIn;
	reg memWriteIn, memReadIn, loadFullWordIn, loadSignedIn;
	reg syscallIn;
	wire [31:0] regData2Out, aluResultOut;
	wire [4:0] writeRegOut;
	wire regWriteOut, memToRegOut;
	wire memWriteOut, memReadOut, loadFullWordOut, loadSignedOut;
	wire syscallOut;

	EXE_MEM_ppreg testPPreg (
		syscallOut, syscallIn,
		regData2Out, regData2In, aluResultOut, aluResultIn,
		writeRegOut, writeRegIn,
		regWriteOut, regWriteIn, memToRegOut, memToRegIn,
		memWriteOut, memWriteIn, memReadOut, memReadIn,
		loadFullWordOut, loadFullWordIn, loadSignedOut, loadSignedIn,
		write, reset, clk);

	initial begin

		$monitor("ALU in: %h, ALU out: %h, writeReg in: %h, writeReg out: %h, LW in: %b, LW out: %b", aluResultIn, aluResultOut, writeRegIn, writeRegOut, loadFullWordIn, loadFullWordOut);

		aluResultIn <= 32'd4;
		writeRegIn <= 5'd5;
		loadFullWordIn <= 1'b0;

		write <= 1;
		#5 clk <= 1;

	end

endmodule
