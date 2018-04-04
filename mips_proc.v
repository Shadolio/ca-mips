module mips_proc ();

	reg clk;
	reg [15:0] cycleNo;

	initial begin
		cycleNo <= 0;
		clk <= 0;
		forever #5 clk <= ~clk;
	end

	initial begin
		$display("MIPS processor starting...");
		$display("Welcome to MIPS processor!");

		$monitor("Cycle %d", cycleNo);
	end

	// [ OUR COMPONENTS WILL BE ADDED HERE IN INTEGRATION ]

	always @(posedge clk)
		cycleNo = cycleNo + 1;

endmodule
