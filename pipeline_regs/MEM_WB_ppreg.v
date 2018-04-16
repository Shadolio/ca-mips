module MEM_WB_ppreg (
	memDataOut, memDataIn, aluResultOut, aluResultIn,
	writeRegOut, writeRegIn,
	regWriteOut, regWriteIn, memToRegOut, memToRegIn,
	write, reset, clk);
	input write, reset, clk;
	input [31:0] memDataIn, aluResultIn;
	input [4:0] writeRegIn;
	input regWriteIn, memToRegIn;
	output [31:0] memDataOut, aluResultOut;
	output [4:0] writeRegOut;
	output regWriteOut, memToRegOut;

	register_32 memDataReg (memDataOut, memDataIn, write, reset, clk);
	register_32 aluResultReg (aluResultOut, aluResultIn, write, reset, clk);

	register_5 writeRegReg (writeRegOut, writeRegIn, write, reset, clk);

	D_FlipFlop regWriteFF	(regWriteOut, regWriteIn, write, reset, clk);
	D_FlipFlop memToRegFF	(memToRegOut, memToRegIn, write, reset, clk);

endmodule

module MEM_WB_ppreg_tb ();
	reg write, reset, clk;
	reg [31:0] memDataIn, aluResultIn;
	reg [4:0] writeRegIn;
	reg regWriteIn, memToRegIn;
	wire [31:0] memDataOut, aluResultOut;
	wire [4:0] writeRegOut;
	wire regWriteOut, memToRegOut;

	MEM_WB_ppreg testPPreg (
		memDataOut, memDataIn, aluResultOut, aluResultIn,
		writeRegOut, writeRegIn,
		regWriteOut, regWriteIn, memToRegOut, memToRegIn,
		write, reset, clk);

	initial begin

		$monitor("ALU in: %h, ALU out: %h, writeReg in: %h, writeReg out: %h, memToRegIin: %b, memToReg out: %b", aluResultIn, aluResultOut, writeRegIn, writeRegOut, memToRegIn, memToRegOut);

		aluResultIn <= 32'd4;
		writeRegIn <= 5'd5;
		memToRegIn <= 1'b1;

		write <= 1;
		#5 clk <= 1;

	end

endmodule
