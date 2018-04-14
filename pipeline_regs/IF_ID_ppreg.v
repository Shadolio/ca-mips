module IF_ID_ppreg (instrOut, pcPlus4Out, instrIn, pcPlus4In, write, reset, clk);
	input write, reset, clk;
	input [31:0] instrIn, pcPlus4In;
	output [31:0] instrOut, pcPlus4Out;

	register_32 instrReg (instrOut, instrIn, write, reset, clk);
	register_32 pcPlus4Reg (pcPlus4Out, pcPlus4In, write, reset, clk);

endmodule

module IF_ID_ppreg_tb ();
	reg write, reset, clk;
	reg [31:0] instrIn, pcPlus4In;
	wire [31:0] instrOut, pcPlus4Out;

	IF_ID_ppreg testPPreg (instrOut, pcPlus4Out, instrIn, pcPlus4In, write, reset, clk);

	initial begin

		$monitor("InstrIn: %h, InstrOut: %h, PC in: %h, PC out: %h", instrIn, instrOut, pcPlus4In, pcPlus4Out);

		instrIn <= 32'h22100002;
		pcPlus4In <= 32'd4;

		write <= 1;
		#5 clk <= 1;

	end

endmodule
