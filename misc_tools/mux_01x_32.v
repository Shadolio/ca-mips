module mux_01x_32 (out, in0, in1, defaultWire, sel);
	input sel;
	input [31:0] in0, in1, defaultWire;
	output reg [31:0] out;

	always @(sel, in0, in1, defaultWire) begin
		case (sel)
			0: out <= in0;
			1: out <= in1;
			default: out <= defaultWire;
		endcase
	end

endmodule

module mux_01x_32_tb ();
	reg sel;
	reg [31:0] in0, in1, defaultValue;
	wire [31:0] out;

	mux_01x_32 testMux (out, in0, in1, defaultValue, sel);

	initial begin

		$monitor("Sel: %b, Out: %h", sel, out);

		in0 <= 32'd16;
		in1 <= 32'h4C;
		defaultValue <= 32'd41;

		#5 sel <= 0;
		#5 sel <= 1;
	end

endmodule
