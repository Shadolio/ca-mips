module mux_2_1 (out, in1, in2, sel);
	input [31:0] in1, in2;
	input sel;
	output [31:0] out;

	assign out = sel == 0 ? in1 : sel == 1 ? in2 : 32'dx;

endmodule

module mux_2_1_tb ();
	reg [31:0] in1, in2;
	reg sel;
	wire [31:0] out;

	mux_2_1 testMux (out, in1, in2, sel);

	initial begin

		in1 <= 32'd17;
		in2 <= 32'd6;

		sel <= 0;

		#10 $display("Value at sel %d is %d", sel, out);
		sel <= 1;

		#10 $display("Value at sel %d is %d", sel, out);
	end

endmodule
