module mux_4_x_32 (out, in0, in1, in2, in3, defaultWire, sel);
	input [1:0] sel;
	input [31:0] in0, in1, in2, in3, defaultWire;
	output reg [31:0] out;

	always @(sel, in0, in1, defaultWire) begin
		case (sel)
			00: out <= in0;
			01: out <= in1;
			10: out <= in2;
			11: out <= in3;
			default: out <= defaultWire;
		endcase
	end

endmodule

module mux_4_x_32_tb ();
	reg [1:0] sel;
	reg [31:0] in0, in1, in2, in3, defaultValue;
	wire [31:0] out;

	mux_4_x_32 testMux (out, in0, in1, in2, in3, defaultValue, sel);

	initial begin

		$monitor("Sel: %b, Out: %h", sel, out);

		in0 <= 32'd16;
		in1 <= 32'h4C;
		in2 <= 32'h2D;
		in3 <= 32'hB3;
		defaultValue <= 32'd41;

		#5 sel <= 2'b00;
		#5 sel <= 2'b01;
		#5 sel <= 2'b10;
		#5 sel <= 2'b11;
	end

endmodule
